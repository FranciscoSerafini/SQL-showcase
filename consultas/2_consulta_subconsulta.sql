/*

LISTAR LOS VENDEDORES QUE EN EL AÑO 2008 SUPERARON EN IMPORTE TOTAL VENDIDO AL MEJOR VENDEDOR DEL AÑO ANTERIOR.

MOSTRAR: vendedor, nombre, importe total

*/
-- 1. OBTENER LAS VENTAS DE LOS VENDEDORES EN EL 2007
-- 2. OBTENER EL MAYOR IMPORTE

SELECT
	v.vendedor,
	SUM(vc.total)
FROM
	vendedores AS v 
	INNER JOIN vencab AS vc ON v.vendedor = vc.vendedor
WHERE
	YEAR(vc.fecha) = 2007 AND
	vc.anulada = 0
GROUP BY
	v.vendedor

SELECT MAX(v2007.imp)
	FROM( SELECT
				v.vendedor,
				SUM(vc.total) AS imp
			FROM
				vendedores AS v 
				INNER JOIN vencab AS vc ON v.vendedor = vc.vendedor
			WHERE
				YEAR(vc.fecha) = 2007 AND
				vc.anulada = 0
			GROUP BY
				v.vendedor) AS v2007

SELECT
	v.vendedor AS 'VENDEDOR',
	v.nombre AS 'NOMBRE',
	SUM(vc.total) AS 'CANTIDAD TOTAL'
FROM
	vendedores AS v
	INNER JOIN vencab AS vc ON v.vendedor = vc.vendedor
WHERE
	vc.anulada = 0 and
	YEAR(vc.fecha) = 2008
GROUP BY
	v.nombre, v.vendedor
HAVING
	SUM(vc.total) > (SELECT MAX(v2007.imp)
						FROM( SELECT
								v.vendedor,
								SUM(vc.total) AS imp
							FROM
								vendedores AS v 
								INNER JOIN vencab AS vc ON v.vendedor = vc.vendedor
							WHERE
								YEAR(vc.fecha) = 2007 AND
								vc.anulada = 0
							GROUP BY
								v.vendedor) AS v2007)
