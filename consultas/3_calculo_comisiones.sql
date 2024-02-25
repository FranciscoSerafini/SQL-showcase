/*

Actividad 1: Consulta SQL (50 puntos)

Realice una consulta donde se calculen las comisiones que le corresponden a cada vendedor para cada mes del a�o 2008, de acuerdo con sus ventas, 
su antig�edad y su categor�a (encargado o no encargado). 

El criterio de c�lculo de las comisiones es el siguiente: 
�	Si el vendedor es encargado, la comisi�n mensual es del 0.05, y se le pagan $500 adicionales por cada a�o de antig�edad.
�	Si el vendedor NO es encargado, la comisi�n mensual es de 0.03 y se le pagan $300 adicionales por cada a�o de antig�edad.
�	Solamente se deben pagar comisiones si el vendedor super� los $5000 en ventas por mes.

El resultado debe mostrar el c�digo del vendedor, el nombre, si es o no encargado, la antig�edad que ten�a en el 2008, el a�o, el mes, el importe total 
de ventas y la comisi�n a cobrar. Ordene por nombre del vendedor, y mes. Excluya ventas anuladas.

*/

SELECT
	v.vendedor AS 'Codigo Vendedor',
	v.nombre AS 'Nombre Vendedor',
	v.encargado AS 'Encargado',
	2008 - YEAR(v.ingreso) AS 'Antiguedad',
	YEAR(v.ingreso) AS 'A�o',
	MONTH(v.ingreso) AS 'Mes',
	SUM(vc.total) AS 'Importe Total',
	SUM(vc.total * 0.05) + (2008 - YEAR(v.ingreso)) * 500 AS 'Comisiones'
FROM
	vendedores AS v 
	INNER JOIN vencab AS vc ON vc.vendedor = v.vendedor
WHERE
	vc.anulada = 0 AND
	YEAR(vc.fecha) = 2008 AND
	v.encargado = 'S'
GROUP BY
	v.vendedor,v.nombre,v.encargado,2008 - YEAR(v.ingreso),	YEAR(v.ingreso) ,MONTH(v.ingreso)
HAVING
	SUM(vc.total) > 5000
--
UNION
--
SELECT
	v.vendedor AS 'Codigo Vendedor',
	v.nombre AS 'Nombre Vendedor',
	v.encargado AS 'Encargado',
	2008 - YEAR(v.ingreso) AS 'Antiguedad',
	YEAR(v.ingreso) AS 'A�o',
	MONTH(v.ingreso) AS 'Mes',
	SUM(vc.total) AS 'Importe Total',
	SUM(vc.total * 0.03) + (2008 - YEAR(v.ingreso)) * 300 AS 'Comisiones'
FROM
	vendedores AS v 
	INNER JOIN vencab AS vc ON vc.vendedor = v.vendedor
WHERE
	vc.anulada = 0 AND
	YEAR(vc.fecha) = 2008 AND
	v.encargado = 'N'
GROUP BY
	v.vendedor,v.nombre,v.encargado,2008 - YEAR(v.ingreso),	YEAR(v.ingreso) ,MONTH(v.ingreso)
HAVING
	SUM(vc.total) > 5000
ORDER BY
	2,6