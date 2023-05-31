drop table if exists categoria;
drop table if exists categoria_simples;
drop table if exists super_categoria;
drop table if exists tem_outra;
drop table if exists produto;
drop table if exists tem_categoria;
drop table if exists IVM;
drop table if exists ponto_de_retalho;
drop table if exists instalada_em;
drop table if exists prateleira;
drop table if exists planograma;
drop table if exists retalhista;
drop table if exists responsavel_por;
drop table if exists evento_reposicao;


CREATE TABLE categoria(
  nome VARCHAR(50) NOT NULL,
  PRIMARY KEY(nome)
);

CREATE TABLE categoria_simples(
  nome VARCHAR(50) NOT NULL,
  PRIMARY KEY(nome),
  FOREIGN KEY(nome) REFERENCES categoria(nome)
);

CREATE TABLE super_categoria(
  nome VARCHAR(50) NOT NULL,
  PRIMARY KEY(nome),
  FOREIGN KEY(nome) REFERENCES categoria(nome)
);

CREATE TABLE tem_outra(
  super_categoria VARCHAR(50) NOT NULL,
  categoria VARCHAR(50) NOT NULL,
  PRIMARY KEY(categoria),
  FOREIGN KEY(super_categoria) REFERENCES super_categoria(nome),
  FOREIGN KEY(categoria) REFERENCES categoria(nome)
);

CREATE TABLE produto(
  ean NUMERIC(13) NOT NULL,
  cat VARCHAR(50) NOT NULL,
  descr VARCHAR(20) NOT NULL,
  PRIMARY KEY(ean),
  FOREIGN KEY(cat) REFERENCES categoria(nome)
);

CREATE TABLE tem_categoria(
  ean NUMERIC(13) NOT NULL,
  nome VARCHAR(50) NOT NULL,
  PRIMARY KEY(ean, nome),
  FOREIGN KEY(ean) REFERENCES produto(ean),
  FOREIGN KEY(nome) REFERENCES categoria(nome)
);

CREATE TABLE IVM(
  num_serie INTEGER NOT NULL,
  fabricante VARCHAR(50),
  PRIMARY KEY(num_serie, fabricante)
);

CREATE TABLE ponto_de_retalho(
  nome VARCHAR(50) NOT NULL,
  distrito VARCHAR(20) NOT NULL,
  concelho VARCHAR(20) NOT NULL,
  PRIMARY KEY(nome)
);

CREATE TABLE instalada_em(
  num_serie INTEGER NOT NULL,
  fabricante VARCHAR(50) NOT NULL,
  local VARCHAR(50) NOT NULL,
  PRIMARY KEY(num_serie, fabricante),
  FOREIGN KEY(num_serie, fabricante) REFERENCES IVM(num_serie, fabricante),
  FOREIGN KEY(local) REFERENCES ponto_de_retalho(nome)
);

CREATE TABLE prateleira(
  nro INTEGER NOT NULL,
  num_serie INTEGER NOT NULL,
  fabricante VARCHAR(50) NOT NULL,
  altura NUMERIC(4,2) NOT NULL,
  nome VARCHAR(50) NOT NULL,
  PRIMARY KEY(nro, num_serie, fabricante),
  FOREIGN KEY(num_serie, fabricante) REFERENCES IVM(num_serie, fabricante),
  FOREIGN KEY(nome) REFERENCES categoria(nome)
);

CREATE TABLE planograma(
  ean NUMERIC(13) NOT NULL,
  nro INTEGER NOT NULL,
  num_serie INTEGER NOT NULL,
  fabricante VARCHAR(50) NOT NULL,
  faces INTEGER,
  unidades INTEGER,
  loc VARCHAR(50),
  PRIMARY KEY(ean, nro, num_serie, fabricante),
  FOREIGN KEY(ean) REFERENCES produto(ean),
  FOREIGN KEY(nro, num_serie, fabricante) REFERENCES prateleira(nro, num_serie, fabricante)
);

CREATE TABLE retalhista(
  tin INTEGER NOT NULL,
  nome VARCHAR(50) NOT NULL,
  PRIMARY KEY(tin),
  UNIQUE(nome)
);

CREATE TABLE responsavel_por(
  nome_cat VARCHAR(50) NOT NULL,
  tin INTEGER NOT NULL,
  num_serie INTEGER NOT NULL,
  fabricante VARCHAR(50) NOT NULL,
  PRIMARY KEY(num_serie, fabricante),
  FOREIGN KEY(num_serie, fabricante) REFERENCES IVM(num_serie, fabricante),
  FOREIGN KEY(tin) REFERENCES retalhista(tin),
  FOREIGN KEY(nome_cat) REFERENCES categoria(nome)
);

CREATE TABLE evento_reposicao(
  ean NUMERIC(13) NOT NULL,
  nro INTEGER NOT NULL,
  num_serie INTEGER NOT NULL,
  fabricante VARCHAR(50) NOT NULL,
  instante TIMESTAMP NOT NULL,
  unidades INTEGER NOT NULL,
  tin INTEGER NOT NULL,
  PRIMARY KEY(ean, nro, num_serie, fabricante, instante),
  FOREIGN KEY(ean, nro, num_serie, fabricante) REFERENCES planograma(ean, nro, num_serie, fabricante),
  FOREIGN KEY(tin) REFERENCES retalhista(tin),
  check(instante < current_timestamp)
);

INSERT INTO categoria VALUES ('Chocolate');
INSERT INTO categoria VALUES ('Bolachas');
INSERT INTO categoria VALUES ('Gelados');
INSERT INTO categoria VALUES ('Sumos');
INSERT INTO categoria VALUES ('Bolachas digestivas');
INSERT INTO categoria VALUES ('Bolachas de chocolate');
INSERT INTO categoria VALUES ('Bolachas de chocolate branco');
INSERT INTO categoria VALUES ('Bolachas de chocolate preto');
INSERT INTO categoria VALUES ('Frutos');

INSERT INTO categoria_simples VALUES ('Chocolate');
INSERT INTO categoria_simples VALUES ('Gelados');
INSERT INTO categoria_simples VALUES ('Sumos');
INSERT INTO categoria_simples VALUES ('Bolachas digestivas');
INSERT INTO categoria_simples VALUES ('Bolachas de chocolate');
INSERT INTO categoria_simples VALUES ('Bolachas de chocolate branco');
INSERT INTO categoria_simples VALUES ('Bolachas de chocolate preto');
INSERT INTO categoria_simples VALUES ('Frutos');

INSERT INTO super_categoria VALUES ('Bolachas');
INSERT INTO super_categoria VALUES ('Bolachas de chocolate');

INSERT INTO tem_outra VALUES ('Bolachas', 'Bolachas digestivas');
INSERT INTO tem_outra VALUES ('Bolachas', 'Bolachas de chocolate');
INSERT INTO tem_outra VALUES ('Bolachas de chocolate', 'Bolachas de chocolate branco');
INSERT INTO tem_outra VALUES ('Bolachas de chocolate', 'Bolachas de chocolate preto');

INSERT INTO produto VALUES (1000000000001, 'Chocolate', 'Chocolate branco');
INSERT INTO produto VALUES (1000000000002, 'Chocolate', 'Chocolate preto');
INSERT INTO produto VALUES (1000000000003, 'Bolachas', 'Bolachas de manteiga');
INSERT INTO produto VALUES (1000000000004, 'Bolachas', 'Bolachas vegan');
INSERT INTO produto VALUES (1000000000005, 'Bolachas de chocolate', 'Choco-cookies');
INSERT INTO produto VALUES (1000000000006, 'Bolachas de chocolate', 'Choco-crackers');
INSERT INTO produto VALUES (1000000000007, 'Bolachas digestivas', 'Belvita');
INSERT INTO produto VALUES (1000000000008, 'Bolachas digestivas', 'Digesfit');
INSERT INTO produto VALUES (1000000000009, 'Gelados', 'Minimilk');
INSERT INTO produto VALUES (1000000000010, 'Gelados', 'Corneto de morango');
INSERT INTO produto VALUES (1000000000011, 'Sumos', 'Compal tuti-fruti');
INSERT INTO produto VALUES (1000000000012, 'Sumos', 'Coca-cola');
INSERT INTO produto VALUES (1000000000013, 'Frutos', 'Ananas');

INSERT INTO tem_categoria VALUES (1000000000001, 'Chocolate');
INSERT INTO tem_categoria VALUES (1000000000002, 'Chocolate');
INSERT INTO tem_categoria VALUES (1000000000003, 'Bolachas');
INSERT INTO tem_categoria VALUES (1000000000004, 'Bolachas');
INSERT INTO tem_categoria VALUES (1000000000005, 'Bolachas de chocolate');
INSERT INTO tem_categoria VALUES (1000000000006, 'Bolachas de chocolate');
INSERT INTO tem_categoria VALUES (1000000000007, 'Bolachas digestivas');
INSERT INTO tem_categoria VALUES (1000000000008, 'Bolachas digestivas');
INSERT INTO tem_categoria VALUES (1000000000009, 'Gelados');
INSERT INTO tem_categoria VALUES (1000000000010, 'Gelados');
INSERT INTO tem_categoria VALUES (1000000000011, 'Sumos');
INSERT INTO tem_categoria VALUES (1000000000012, 'Sumos');
INSERT INTO tem_categoria VALUES (1000000000013, 'Frutos');

INSERT INTO IVM VALUES (123100, 'Maquinas do Arnaldo');
INSERT INTO IVM VALUES (123101, 'Maquinas do Arnaldo');
INSERT INTO IVM VALUES (123100, 'Jesualdo e co.');
INSERT INTO IVM VALUES (123103, 'Andre e filhos');
INSERT INTO IVM VALUES (123101, 'Joao e pais');

INSERT INTO ponto_de_retalho VALUES ('Galp - Oeiras', 'Lisboa', 'Oeiras');
INSERT INTO ponto_de_retalho VALUES ('Continente - Telheiras', 'Lisboa', 'Lisboa');
INSERT INTO ponto_de_retalho VALUES ('Pingo Doce - Mirandela', 'Bragança', 'Mirandela');
INSERT INTO ponto_de_retalho VALUES ('Lidl - Viana do Castelo', 'Minho', 'Viana do Castelo');

INSERT INTO instalada_em VALUES (123100, 'Maquinas do Arnaldo', 'Galp - Oeiras');
INSERT INTO instalada_em VALUES (123101, 'Maquinas do Arnaldo', 'Continente - Telheiras');
INSERT INTO instalada_em VALUES (123100, 'Jesualdo e co.', 'Pingo Doce - Mirandela');
INSERT INTO instalada_em VALUES (123103, 'Andre e filhos', 'Pingo Doce - Mirandela');
INSERT INTO instalada_em VALUES (123101, 'Joao e pais', 'Lidl - Viana do Castelo');

INSERT INTO prateleira VALUES (1, 123100, 'Maquinas do Arnaldo', 10.25, 'Chocolate');
INSERT INTO prateleira VALUES (2, 123100, 'Maquinas do Arnaldo', 10.25, 'Chocolate');
INSERT INTO prateleira VALUES (1, 123101, 'Maquinas do Arnaldo', 8.50, 'Bolachas digestivas');
INSERT INTO prateleira VALUES (2, 123101, 'Maquinas do Arnaldo', 8.50, 'Bolachas digestivas');
INSERT INTO prateleira VALUES (1, 123100, 'Jesualdo e co.', 23.45, 'Gelados');
INSERT INTO prateleira VALUES (2, 123100, 'Jesualdo e co.', 23.45, 'Gelados');
INSERT INTO prateleira VALUES (1, 123103, 'Andre e filhos', 10.80, 'Sumos');
INSERT INTO prateleira VALUES (2, 123103, 'Andre e filhos', 10.80, 'Sumos');
INSERT INTO prateleira VALUES (1, 123101, 'Joao e pais', 46.75, 'Frutos');
INSERT INTO prateleira VALUES (2, 123101, 'Joao e pais', 46.75, 'Frutos');

INSERT INTO planograma VALUES (1000000000001, 1, 123100, 'Maquinas do Arnaldo', 5, 50);
INSERT INTO planograma VALUES (1000000000002, 1, 123100, 'Maquinas do Arnaldo', 3, 30);
INSERT INTO planograma VALUES (1000000000001, 2, 123100, 'Maquinas do Arnaldo', 5, 50);
INSERT INTO planograma VALUES (1000000000002, 2, 123100, 'Maquinas do Arnaldo', 3, 30);
INSERT INTO planograma VALUES (1000000000007, 1, 123101, 'Maquinas do Arnaldo', 3, 30);
INSERT INTO planograma VALUES (1000000000008, 1, 123101, 'Maquinas do Arnaldo', 5, 50);
INSERT INTO planograma VALUES (1000000000007, 2, 123101, 'Maquinas do Arnaldo', 3, 30);
INSERT INTO planograma VALUES (1000000000008, 2, 123101, 'Maquinas do Arnaldo', 5, 50);
INSERT INTO planograma VALUES (1000000000009, 1, 123100, 'Jesualdo e co.', 4, 40);
INSERT INTO planograma VALUES (1000000000010, 1, 123100, 'Jesualdo e co.', 6, 60);
INSERT INTO planograma VALUES (1000000000009, 2, 123100, 'Jesualdo e co.', 4, 60);
INSERT INTO planograma VALUES (1000000000010, 2, 123100, 'Jesualdo e co.', 6, 60);
INSERT INTO planograma VALUES (1000000000011, 1, 123103, 'Andre e filhos', 7, 70);
INSERT INTO planograma VALUES (1000000000012, 1, 123103, 'Andre e filhos', 4, 40);
INSERT INTO planograma VALUES (1000000000011, 2, 123103, 'Andre e filhos', 7, 70);
INSERT INTO planograma VALUES (1000000000012, 2, 123103, 'Andre e filhos', 4, 40);
INSERT INTO planograma VALUES (1000000000013, 1, 123101, 'Joao e pais', 10, 100);
INSERT INTO planograma VALUES (1000000000013, 2, 123101, 'Joao e pais', 10, 100);

INSERT INTO retalhista VALUES (100001, 'Antonio Miguel');
INSERT INTO retalhista VALUES (100002, 'Marcelo Marcelino');
INSERT INTO retalhista VALUES (100003, 'Manuel Rogerio');
INSERT INTO retalhista VALUES (100004, 'Mariana Maximino');
INSERT INTO retalhista VALUES (100005, 'Andre Robalo');

INSERT INTO responsavel_por VALUES ('Chocolate', 100001, 123100, 'Maquinas do Arnaldo');
INSERT INTO responsavel_por VALUES ('Bolachas digestivas', 100002, 123101, 'Maquinas do Arnaldo');
INSERT INTO responsavel_por VALUES ('Gelados', 100003, 123100, 'Jesualdo e co.');
INSERT INTO responsavel_por VALUES ('Sumos', 100004, 123103, 'Andre e filhos');
INSERT INTO responsavel_por VALUES ('Frutos', 100005, 123101, 'Joao e pais');

INSERT INTO evento_reposicao VALUES (1000000000001, 1, 123100, 'Maquinas do Arnaldo', TIMESTAMP '2022-05-21', 12, 100001);
INSERT INTO evento_reposicao VALUES (1000000000002, 1, 123100, 'Maquinas do Arnaldo', TIMESTAMP '2022-05-21', 10, 100001);
INSERT INTO evento_reposicao VALUES (1000000000001, 2, 123100, 'Maquinas do Arnaldo', TIMESTAMP '2022-05-21', 8, 100001);
INSERT INTO evento_reposicao VALUES (1000000000002, 2, 123100, 'Maquinas do Arnaldo', TIMESTAMP '2022-05-21', 5, 100001);
INSERT INTO evento_reposicao VALUES (1000000000007, 1, 123101, 'Maquinas do Arnaldo', TIMESTAMP '2022-05-23', 12, 100002);
INSERT INTO evento_reposicao VALUES (1000000000008, 1, 123101, 'Maquinas do Arnaldo', TIMESTAMP '2022-05-23', 12, 100002);
INSERT INTO evento_reposicao VALUES (1000000000007, 2, 123101, 'Maquinas do Arnaldo', TIMESTAMP '2022-05-23', 6, 100002);
INSERT INTO evento_reposicao VALUES (1000000000008, 2, 123101, 'Maquinas do Arnaldo', TIMESTAMP '2022-05-23', 5, 100002);
INSERT INTO evento_reposicao VALUES (1000000000009, 1, 123100, 'Jesualdo e co.', TIMESTAMP '2022-05-26', 10, 100003);
INSERT INTO evento_reposicao VALUES (1000000000010, 1, 123100, 'Jesualdo e co.', TIMESTAMP '2022-05-26', 10, 100003);
INSERT INTO evento_reposicao VALUES (1000000000009, 2, 123100, 'Jesualdo e co.', TIMESTAMP '2022-05-26', 10, 100003);
INSERT INTO evento_reposicao VALUES (1000000000010, 2, 123100, 'Jesualdo e co.', TIMESTAMP '2022-05-27', 10, 100003);
INSERT INTO evento_reposicao VALUES (1000000000011, 1, 123103, 'Andre e filhos', TIMESTAMP '2022-05-27', 10, 100004);
INSERT INTO evento_reposicao VALUES (1000000000012, 2, 123103, 'Andre e filhos', TIMESTAMP '2022-05-27', 10, 100004);
INSERT INTO evento_reposicao VALUES (1000000000011, 1, 123103, 'Andre e filhos', TIMESTAMP '2022-05-29', 10, 100004);
INSERT INTO evento_reposicao VALUES (1000000000012, 2, 123103, 'Andre e filhos', TIMESTAMP '2022-05-29', 10, 100004);
INSERT INTO evento_reposicao VALUES (1000000000013, 1, 123101, 'Joao e pais', TIMESTAMP '2022-05-30', 6, 100005);
INSERT INTO evento_reposicao VALUES (1000000000013, 2, 123101, 'Joao e pais', TIMESTAMP '2022-06-01', 8, 100005);