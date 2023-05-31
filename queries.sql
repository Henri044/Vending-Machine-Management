SELECT nome 
FROM retalhista NATURAL JOIN responsavel_por
GROUP BY tin
HAVING COUNT(nome_cat) >= ALL (
  SELECT COUNT(nome_cat)
  FROM retalhista NATURAL JOIN responsavel_por
  GROUP BY tin
);


SELECT DISTINCT nome
FROM retalhista NATURAL JOIN responsavel_por
WHERE nome_cat IN (
  SELECT *
  FROM categoria_simples
);


SELECT ean
FROM produto
WHERE ean NOT IN (
  SELECT ean
  FROM evento_reposicao
  GROUP BY ean
);


SELECT ean
FROM evento_reposicao
GROUP BY ean
HAVING COUNT(DISTINCT(tin)) = 1;