/*

EJERCICIO 1

Crear el procedimiento almacenado "sp_actualiza_precios_rubro", que solicite tres parámetros: 1) código del rubro, 2) porcentaje de
modificación de preciomenor, y 3) porcentaje de modificación de precio mayor.

El procedimiento deberá validar que el rubro exista, y retornar en un mensaje la cantidad de filas que se actualizaron al finalizar.

Se deberá validar la ocurrencia de errores utilizando TRY / CATCH, y utilizar TRANSACCIONES para volver atrás los 
cambios en caso de ocurrir alguno.

*/

SELECT * FROM rubros
CREATE OR ALTER PROCEDURE sp_actualiza_precios_rubros
@codigo int,
@porcenMenor decimal,
@porcenMayor decimal
AS
DECLARE @filas int
BEGIN TRY
	BEGIN TRANSACTION
	BEGIN
		IF NOT EXISTS(SELECT * FROM rubros WHERE rubro = @codigo)
			BEGIN
				PRINT'EL RUBRO INGRESADO NO EXISTE' + TRIM(STR(@CODIGO))
				GOTO FIN
			END
		ELSE
			BEGIN
				UPDATE articulos
				SET preciomenor = preciomenor + (preciomenor * @porcenMenor/100),
					preciomayor = preciomayor + (preciomayor * @porcenMayor/100)
				WHERE
					rubro = @codigo
				--
				SET @filas = @@ROWCOUNT
				--
				COMMIT TRANSACTION
			END
		IF @filas > 0
			BEGIN
				PRINT'SE INSERTARON: ' + TRIM(STR(@filas)) + ' FILAS.'
			END
		ELSE
			PRINT'NO HUBO INSERCIONES DE FILAS'
	END
FIN:
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT'ERROR EN LA EJECUCION DEL CODIGO:' + CONVERT(NVARCHAR(50), ERROR_MESSAGE())
END CATCH

EXEC sp_actualiza_precios_rubros 5,-10,-10
SELECT articulo,preciomenor, preciomayor FROM articulos WHERE rubro = 5
			
			
