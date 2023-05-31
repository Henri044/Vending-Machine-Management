SELECT dia_semana, concelho, SUM(unidades)
FROM vendas
WHERE DATE(CONCAT(ano, '-', mes, '-', dia_mes)) BETWEEN '2022-05-25' AND '2022-06-30'
GROUP BY
  GROUPING SETS ((dia_semana), (concelho), ());


SELECT concelho, cat, dia_semana, SUM(unidades)
FROM vendas
WHERE distrito = 'Lisboa'
GROUP BY
  GROUPING SETS ((concelho), (cat), (dia_semana), ());