
/*
Realice una consulta donde se calculen las comisiones que le corresponden a cada vendedor para cada mes del año 2008, de acuerdo con sus ventas, 
su antigüedad y su categoría (encargado o no encargado). 

El criterio de cálculo de las comisiones es el siguiente: 
•	Si el vendedor es encargado, la comisión mensual es del 0.05, y se le pagan $500 adicionales por cada año de antigüedad.
•	Si el vendedor NO es encargado, la comisión mensual es de 0.03 y se le pagan $300 adicionales por cada año de antigüedad.
•	Solamente se deben pagar comisiones si el vendedor superó los $5000 en ventas por mes.

El resultado debe mostrar el código del vendedor, el nombre, si es o no encargado, la antigüedad que tenía en el 2008, el año, el mes, el importe total 
de ventas y la comisión a cobrar. Ordene por nombre del vendedor, y mes. Excluya ventas anuladas.

*/

SELECT -- ENCARGADOS
	v.vendedor AS 'Codigo Vendedor',
	v.nombre AS 'Nombre Vendedor',
	v.encargado AS 'Encargado',
	2008 - YEAR(v.ingreso) AS 'Antiguedad',
	YEAR(v.ingreso) AS 'Año de ingreso',
	MONTH(v.ingreso) AS 'Mes de ingreso',
	SUM(vc.total) AS 'Importe Total de Ventas',
	SUM(vc.total * 0.05) +(2008 - YEAR(v.ingreso)) * 500 AS 'Comision'
FROM
	vendedores AS v
	INNER JOIN vencab AS vc ON vc.vendedor = v.vendedor
WHERE
	v.encargado = 'S' AND
	vc.anulada = 0 AND
	YEAR(vc.fecha) = 2008
GROUP BY
	v.vendedor, v.nombre,v.encargado,2008 - YEAR(v.ingreso),YEAR(v.ingreso),MONTH(v.ingreso)
HAVING
	SUM(vc.total) > 5000

--
UNION
--
SELECT -- no ENCARGADOS
	v.vendedor AS 'Codigo Vendedor',
	v.nombre AS 'Nombre Vendedor',
	v.encargado AS 'Encargado',
	2008 - YEAR(v.ingreso) AS 'Antiguedad',
	YEAR(v.ingreso) AS 'Año de ingreso',
	MONTH(v.ingreso) AS 'Mes de ingreso',
	SUM(vc.total) AS 'Importe Total de Ventas',
	SUM(vc.total * 0.03) +(2008 - YEAR(v.ingreso)) * 300 AS 'Comision'
FROM
	vendedores AS v
	INNER JOIN vencab AS vc ON vc.vendedor = v.vendedor
WHERE
	v.encargado = 'N' AND
	vc.anulada = 0 AND
	YEAR(vc.fecha) = 2008
GROUP BY
	v.vendedor, v.nombre,v.encargado,2008 - YEAR(v.ingreso),YEAR(v.ingreso),MONTH(v.ingreso)
HAVING
	SUM(vc.total) > 5000
ORDER BY
	2,6

/*

Actividad 2: Procedimiento Almacenado (50 puntos)

Tomando como base la consulta anterior, implemente un procedimiento almacenado que se denomine sp_comisiones_vendedores, que reciba 
como parámetros los valores marcados en rojo en el enunciado anterior: año, comisión encargado, adicional encargado, comisión vendedor, 
adicional vendedor, mínimo de ventas. 

El procedimiento deberá generar generar la tabla tmp_comisiones_vendedores con las filas retornadas del resultado, mostrando mostrando 
el mensaje “El procedimiento finalizó correctamente. Se insertaron [..] filas.” en caso de funcionamiento correcto, o “Se produjo un error 
durante la inserción. La tabla no fue actualizada.” en caso contrario.

Ejemplo de ejecución:

EXEC sp_comisiones_vendedores 2008, 0.05, 500, 0.03, 300, 5000

*/
CREATE OR ALTER PROCEDURE sp_comisiones_vendedores_2
@año int,
@comEnc decimal,
@adiEnc int,
@comVen decimal,
@adiVen int,
@minVen int
AS
DECLARE @mensaje nvarchar(255) = '';
DECLARE @filas int
BEGIN TRY
	BEGIN TRANSACTION
		BEGIN
			-- Verificar y eliminar tabla temporal si existe
			IF OBJECT_ID('temp_comisiones_vendedores_2') IS NOT NULL
				DROP TABLE temp_comisiones_vendedores_2
			SELECT 
				v.vendedor AS 'Codigo Vendedor',
				v.nombre AS 'Nombre Vendedor',
				v.encargado AS 'Encargado',
				2008 - YEAR(v.ingreso) AS 'Antiguedad',
				YEAR(v.ingreso) AS 'Año de ingreso',
				MONTH(v.ingreso) AS 'Mes de ingreso',
				SUM(vc.total) AS 'Importe Total de Ventas',
				CASE v.encargado
					WHEN 'S' THEN SUM(vc.total * @comEnc) +(2008 - YEAR(v.ingreso)) * @adiEnc
					WHEN 'N' THEN SUM(vc.total * @comVen) +(2008 - YEAR(v.ingreso)) * @adiVen
				
				END AS 'COMISIONES'
			INTO
				temp_comisiones_vendedores_2
			FROM
				vendedores AS v
				INNER JOIN vencab AS vc ON vc.vendedor = v.vendedor	
			WHERE
				vc.anulada = 0 AND
				YEAR(vc.fecha) = @año
			GROUP BY
				v.vendedor, v.nombre,v.encargado,2008 - YEAR(v.ingreso),YEAR(v.ingreso),MONTH(v.ingreso)
			HAVING
				SUM(vc.total) > @minVen
			ORDER BY
				2,6
			--
			SET @filas = @@ROWCOUNT
			--
			COMMIT TRANSACTION
			--
			PRINT'EL PROCEDIMIENTO FINALIZO SIN ERRORES'
			PRINT' SE INSERTARON: ' + TRIM(STR(@filas)) + ' FILAS'
		END
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT 'EL PROCEDIMIENTO FINALIZO CON ERRORES, VERIFICAR CON EL ADMINISTRADOR'
	PRINT 'ERROR: ' + CONVERT(nvarchar(50), ERROR_MESSAGE())
END CATCH

EXEC sp_comisiones_vendedores_2 2008, 0.05, 500, 0.03, 300, 100000 -- para ejecutarlo
SELECT * FROM temp_comisiones_vendedores_2 -- para verificar la tabla

-- Autor: Francisco Serafini Giorgi
-- Fecha: 24/02/2024

-- Descripción: Procedimiento almacenado para calcular comisiones de vendedores.
	
		
