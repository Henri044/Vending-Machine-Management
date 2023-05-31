CREATE VIEW vendas(ean, cat, ano, trimestre, mes, dia_mes, dia_semana, distrito, concelho, unidades) AS
SELECT a.ean, a.nome, extract(YEAR FROM b.instante), extract(QUARTER FROM b.instante), extract(MONTH FROM b.instante), extract(DAY FROM b.instante), extract(DOW FROM b.instante), d.distrito, d.concelho, b.unidades
FROM tem_categoria AS a JOIN evento_reposicao AS b ON a.ean=b.ean 
     JOIN instalada_em AS c ON b.num_serie=c.num_serie AND b.fabricante=c.fabricante 
     JOIN ponto_de_retalho AS d ON c.local=d.nome