CREATE OR REPLACE FUNCTION	cat_proc()	
RETURNS TRIGGER AS
$$
BEGIN
	IF NEW.super_categoria = NEW.categoria THEN
		RAISE EXCEPTION 'Uma Categoria não pode estar contida em si própria';
	END IF;
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER cat_trigger	
BEFORE INSERT ON tem_outra	
FOR EACH ROW EXECUTE PROCEDURE cat_proc();



CREATE OR REPLACE FUNCTION	limite_evento_repos_proc()	
RETURNS TRIGGER AS
$$
DECLARE un INTEGER;
BEGIN
	SELECT unidades INTO un
	FROM planograma 
	WHERE (planograma.ean = NEW.ean AND planograma.nro = NEW.nro AND planograma.num_serie = NEW.num_serie AND planograma.fabricante = NEW.fabricante);
	IF NEW.unidades > un THEN
		RAISE EXCEPTION 'O numero de unidades repostas num Evento de Reposicao nao pode exceder o numero de unidades especificado pelo Planograma';
	END IF;
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER limite_evento_repos_trigger	
BEFORE INSERT ON evento_reposicao	
FOR EACH ROW EXECUTE PROCEDURE limite_evento_repos_proc();



CREATE OR REPLACE FUNCTION	produto_prateleira_proc()	
RETURNS TRIGGER AS
$$
DECLARE cat_name VARCHAR(50);
DECLARE cat_name_prat VARCHAR(50);
BEGIN
	SELECT cat INTO cat_name
	FROM produto
	WHERE produto.ean = NEW.ean;

	SELECT nome INTO cat_name_prat
	FROM prateleira
	WHERE (prateleira.nro = NEW.nro AND prateleira.num_serie = NEW.num_serie AND prateleira.fabricante = NEW.fabricante);

	IF cat_name NOT LIKE cat_name_prat THEN
		RAISE EXCEPTION 'Um Produto só pode ser reposto numa Prateleira que apresente (pelo menos) uma das Categorias desse produto';
	END IF;
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER produto_prateleira_trigger	
BEFORE INSERT ON evento_reposicao	
FOR EACH ROW EXECUTE PROCEDURE produto_prateleira_proc();