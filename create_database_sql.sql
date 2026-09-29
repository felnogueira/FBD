DROP DATABASE IF EXISTS `ENEM`;
CREATE DATABASE `ENEM` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; # Define conjunto de caracteres para suportar simbolos especiais da lingua portuguesa
USE `ENEM`;

CREATE TABLE EDICAO_ENEM (
	EDICAO YEAR NOT NULL,
    PRIMARY KEY (EDICAO)
);

CREATE TABLE REGIAO (
	CO_REGIAO TINYINT UNSIGNED NOT NULL, # TINYINT UNSIGNED pois os valores variam de 0 a 5
    NO_REGIAO VARCHAR(20) NOT NULL, # Nome de regiao com um pouco de margem caso valores extrapolem
    PRIMARY KEY (CO_REGIAO)
);

CREATE TABLE UNIDADE_FEDERATIVA (
	CO_UF TINYINT UNSIGNED NOT NULL, # TINYINT UNSIGNED pois os valores variam de 11 a 53
    NO_UF VARCHAR(30) NOT NULL, # Nome de UF com um pouco de margem caso valores extrapolem
    SG_UF CHAR(2) NOT NULL,
    CO_REGIAO TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (CO_UF),
    FOREIGN KEY (CO_REGIAO) 
		REFERENCES REGIAO(CO_REGIAO), # Relacionamento 1:N com a chave estrangeira do lado N
	CONSTRAINT UNQ_SG_UF UNIQUE (SG_UF) # Garantir que a sigla de cada UF seja unico
);

CREATE TABLE REGIAO_GEOGRAFICA_INTERMEDIARIA (
	CO_RG_INTERMED INT UNSIGNED NOT NULL, # UNSIGNED pois codigos de regiao nao sao negativos
    NO_RG_INTERMED VARCHAR(100) NOT NULL, # Nome de Regiao Intermediaria com um pouco de margem caso valores extrapolem
    CO_UF TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (CO_RG_INTERMED),
    FOREIGN KEY (CO_UF) 
		REFERENCES UNIDADE_FEDERATIVA(CO_UF) # Relacionamento 1:N com a chave estrangeira do lado N
);

CREATE TABLE REGIAO_GEOGRAFICA_IMEDIATA (
	CO_RG_IMED INT UNSIGNED NOT NULL, # UNSIGNED pois codigos de regiao nao sao negativos
    NO_RG_IMED VARCHAR(100) NOT NULL, # Nome de Regiao Imediata com um pouco de margem caso valores extrapolem
    CO_RG_INTERMED INT UNSIGNED NOT NULL,
    PRIMARY KEY (CO_RG_IMED),
    FOREIGN KEY (CO_RG_INTERMED) 
		REFERENCES REGIAO_GEOGRAFICA_INTERMEDIARIA(CO_RG_INTERMED) # Relacionamento 1:N com a chave estrangeira do lado N
);

CREATE TABLE MUNICIPIO (
	CO_MUNICIPIO INT UNSIGNED NOT NULL, # UNSIGNED pois codigos de regiao nao sao negativos
    NO_MUNICIPIO VARCHAR(50) NOT NULL, # Nome de Municipio com um pouco de margem caso valores extrapolem
    CO_RG_IMED INT UNSIGNED NOT NULL,
    PRIMARY KEY (CO_MUNICIPIO),
    FOREIGN KEY (CO_RG_IMED)
		REFERENCES REGIAO_GEOGRAFICA_IMEDIATA(CO_RG_IMED) # Relacionamento 1:N com a chave estrangeira do lado N
);

CREATE TABLE QUESTAO_QUESTIONARIO (
	COD_QUESTAO CHAR(4) NOT NULL, # Codigos de questao seguem o formato Q001
    DESCRICAO VARCHAR(300) NOT NULL, # Descricao da pergunta sendo feita no questionario socioeconomico
    PRIMARY KEY (COD_QUESTAO)
);

CREATE TABLE PROVA (
	CO_PROVA INT UNSIGNED NOT NULL, # UNSIGNED pois provas nao possuem codigos negativos
    SG_AREA CHAR(2) NOT NULL, # Sigla da area de conhecimento
    TX_COR VARCHAR(30), # Cor da prova
    ANO_ENEM YEAR NOT NULL,
    PRIMARY KEY (CO_PROVA),
    FOREIGN KEY (ANO_ENEM)
		REFERENCES EDICAO_ENEM(EDICAO) # Relacionamento 1:N com a chave estrangeira do lado N
);

CREATE TABLE PARTICIPANTE (
	NU_INSCRICAO BIGINT NOT NULL, # BIGINT pois os numeros de inscricao possuem 12 digitos
    TP_SEXO CHAR(1) NOT NULL, # Sexo 'M' ou 'F'
    TP_FAIXA_ETARIA INT UNSIGNED NOT NULL, # Indica o grupo de faixa etaria do participante
    TP_ESTADO_CIVIL TINYINT, # TINYINT pois os valores deste e dos proximos campos ficam entre 0 e 6
    TP_COR_RACA TINYINT,
    TP_NACIONALIDADE TINYINT NOT NULL,
    TP_ST_CONCLUSAO TINYINT, # Estado de conclusao do ensino medio
    IN_TREINEIRO TINYINT NOT NULL, # Indica se participante é treineiro ou nao
    CO_MUNICIPIO_ESCOLA INT UNSIGNED, # Municipio onde o participante estuda. 
    CO_MUNICIPIO_PROVA INT UNSIGNED, # Municipio onde o participante fez a prova
    ANO_ENEM YEAR NOT NULL,
    PRIMARY KEY (NU_INSCRICAO),
    FOREIGN KEY (CO_MUNICIPIO_ESCOLA) 
		REFERENCES MUNICIPIO (CO_MUNICIPIO), # Relacionamento 1:N com a chave estrangeira do lado N
    FOREIGN KEY (CO_MUNICIPIO_PROVA)
		REFERENCES MUNICIPIO (CO_MUNICIPIO), # Relacionamento 1:N com a chave estrangeira do lado N
	FOREIGN KEY (ANO_ENEM)
		REFERENCES EDICAO_ENEM (EDICAO), # Relacionamento 1:N com a chave estrangeira do lado N
	CONSTRAINT CHK_SEXO CHECK (TP_SEXO IN ('M', 'F')), # Validar que sexo do participante é 'M' ou 'F'
    CONSTRAINT CHK_IDADE CHECK (TP_FAIXA_ETARIA BETWEEN 1 AND 20), # Validar que grupo etario do participante é valido
    CONSTRAINT CHK_ESTADO_CIVIL CHECK (TP_ESTADO_CIVIL BETWEEN 0 AND 4), # Validar que estado civil do participante é valido
    CONSTRAINT CHK_RACA CHECK (TP_COR_RACA BETWEEN 0 AND 6), # Validar que a raça do participante corresponde às opções fornecidas pelo INEP
    CONSTRAINT CHK_NACIONALIDADE CHECK (TP_NACIONALIDADE BETWEEN 0 AND 4), # Validar que a nacionaliade do participante é valida
    CONSTRAINT CHK_CONCLUSAO CHECK (TP_ST_CONCLUSAO BETWEEN 1 AND 4), # Validar que o estado de conclusao do ensino medio é valido
    CONSTRAINT CHK_TREINEIRO CHECK (IN_TREINEIRO BETWEEN 0 AND 1) # Validar se a situacao de realizacao de prova é valida
);

CREATE TABLE RESPOSTA_QUESTIONARIO ( # Relacionamento entre PARTICIPANTE e QUESTAO_QUESTIONARIO é N:N -> Necessaria a criacao de uma tabela para a relacao
	NU_INSCRICAO BIGINT NOT NULL,
    COD_QUESTAO CHAR(4) NOT NULL,
    RESPOSTA CHAR(2),
    PRIMARY KEY (NU_INSCRICAO, COD_QUESTAO),
    FOREIGN KEY (NU_INSCRICAO)
		REFERENCES PARTICIPANTE(NU_INSCRICAO),
	FOREIGN KEY (COD_QUESTAO)
		REFERENCES QUESTAO_QUESTIONARIO(COD_QUESTAO)
);

CREATE TABLE RESULTADO_REDACAO (
	ID_RESULTADO_RED INT NOT NULL, # Chave artificial criada no processo de ETL
    NU_INSCRICAO BIGINT NOT NULL,
    TP_STATUS_REDACAO TINYINT NOT NULL, # TINYINT pois a faixa de valores para o campo está entre 0 e 9
    NU_NOTA_COMP1 DECIMAL(5,2), # DECIMAL para melhor representacao dos valores
    NU_NOTA_COMP2 DECIMAL(5,2), # Cada NU_NOTA_COMP representa uma competencia e pode variar de 0 a 200
    NU_NOTA_COMP3 DECIMAL(5,2), # Portanto, 5 digitos com 2 casas decimais atende o cenario
    NU_NOTA_COMP4 DECIMAL(5,2),
    NU_NOTA_COMP5 DECIMAL(5,2),
    NU_NOTA_REDACAO DECIMAL(6,2), # Somatorio de todos NU_NOTA_COMP. Como 1000,00 é possivel, sao necessarios 6 digitos
    PRIMARY KEY (ID_RESULTADO_RED),
    FOREIGN KEY (NU_INSCRICAO) # Relacionamento (1,1) : (0,1)
		REFERENCES PARTICIPANTE(NU_INSCRICAO), # Chave estrangeira fica melhor posicionada no lado (0,1)
	CONSTRAINT CHK_RED_STATUS CHECK (TP_STATUS_REDACAO BETWEEN 1 AND 4 OR TP_STATUS_REDACAO BETWEEN 6 AND 9), # Valida que o estado da redacao é valido
    CONSTRAINT UNQ_NU_INSC UNIQUE (NU_INSCRICAO), # Garante que o numero de inscricao do participante é unico
    CONSTRAINT CHK_NOTA_COMP1 CHECK (NU_NOTA_COMP1 BETWEEN 0 AND 200), # Valida que NU_NOTA_COMP esta entre 0 e 200
    CONSTRAINT CHK_NOTA_COMP2 CHECK (NU_NOTA_COMP2 BETWEEN 0 AND 200),
    CONSTRAINT CHK_NOTA_COMP3 CHECK (NU_NOTA_COMP3 BETWEEN 0 AND 200),
    CONSTRAINT CHK_NOTA_COMP4 CHECK (NU_NOTA_COMP4 BETWEEN 0 AND 200),
    CONSTRAINT CHK_NOTA_COMP5 CHECK (NU_NOTA_COMP5 BETWEEN 0 AND 200),
    CONSTRAINT CHK_NOTA_REDACAO CHECK (NU_NOTA_REDACAO = 
    NU_NOTA_COMP1 + NU_NOTA_COMP2 + NU_NOTA_COMP3 + NU_NOTA_COMP4 + NU_NOTA_COMP5) # Valida que a nota da redacao é igual a somatoria das NU_NOTA_COMP
);

CREATE TABLE RESULTADO_PROVA ( # Relacionamento entre PARTICIPANTE e PROVA é N:N -> Necessaria a criacao de uma tabela para a relacao
	NU_INSCRICAO BIGINT NOT NULL,
    CO_PROVA INT UNSIGNED NOT NULL,
    TP_PRESENCA TINYINT NOT NULL, # Situacao de presenca do participante
    NU_NOTA DECIMAL(6,2), # DECIMAL para melhor representacao dos valores
    TP_LINGUA TINYINT, # Lingua estrangeira escolhida na prova de linguagens. É NULL para as outras provas
    PRIMARY KEY (NU_INSCRICAO, CO_PROVA),
    FOREIGN KEY (NU_INSCRICAO)
		REFERENCES PARTICIPANTE(NU_INSCRICAO),
	FOREIGN KEY (CO_PROVA)
		REFERENCES PROVA(CO_PROVA),
	CONSTRAINT CHK_PRESENCA CHECK (TP_PRESENCA BETWEEN 0 AND 2), # Valida situacao de presenca do participante
    CONSTRAINT CHK_TP_LINGUA CHECK (TP_LINGUA BETWEEN 0 AND 1), # Valida a lingua estrangeira da prova
    CONSTRAINT CHK_NOTA_MIN CHECK (NU_NOTA >= 0) # Valida que a nota nao é negativa
);

#------------------ VIEW------------------#

DROP VIEW IF EXISTS RESULTADO_COMPLETO;
CREATE VIEW RESULTADO_COMPLETO AS
SELECT R.NU_INSCRICAO, R.IN_TREINEIRO, R.TP_LINGUA, R.TP_PRESENCA_PROVA_CN, R.NOTA_PROVA_CN, R.TP_PRESENCA_PROVA_CH,
	R.NOTA_PROVA_CH, R.TP_PRESENCA_PROVA_LC, R.NOTA_PROVA_LC, R.TP_PRESENCA_PROVA_MT, R.NOTA_PROVA_MT, R.TP_STATUS_REDACAO,
    R.NU_NOTA_REDACAO,
	ROUND((R.NOTA_PROVA_CN + R.NOTA_PROVA_CH + R.NOTA_PROVA_LC + R.NOTA_PROVA_MT + R.NU_NOTA_REDACAO) / 5,2) AS NOTA_FINAL,
    R.ANO_ENEM, R.MUNICIPIO_PROVA, R.UF_PROVA
    FROM(
	SELECT RESULTADO_PROVA.NU_INSCRICAO,
		PARTICIPANTE.IN_TREINEIRO,
		MAX(TP_LINGUA) AS TP_LINGUA,
		MAX(CASE WHEN PROVA.SG_AREA = 'CN' THEN RESULTADO_PROVA.TP_PRESENCA END) AS TP_PRESENCA_PROVA_CN,
		MAX(CASE WHEN PROVA.SG_AREA = 'CN' THEN RESULTADO_PROVA.NU_NOTA END) AS NOTA_PROVA_CN,
		MAX(CASE WHEN PROVA.SG_AREA = 'CH' THEN RESULTADO_PROVA.TP_PRESENCA END) AS TP_PRESENCA_PROVA_CH,
		MAX(CASE WHEN PROVA.SG_AREA = 'CH' THEN RESULTADO_PROVA.NU_NOTA END) AS NOTA_PROVA_CH,
		MAX(CASE WHEN PROVA.SG_AREA = 'LC' THEN RESULTADO_PROVA.TP_PRESENCA END) AS TP_PRESENCA_PROVA_LC,
		MAX(CASE WHEN PROVA.SG_AREA = 'LC' THEN RESULTADO_PROVA.NU_NOTA END) AS NOTA_PROVA_LC,
		MAX(CASE WHEN PROVA.SG_AREA = 'MT' THEN RESULTADO_PROVA.TP_PRESENCA END) AS TP_PRESENCA_PROVA_MT,
		MAX(CASE WHEN PROVA.SG_AREA = 'MT' THEN RESULTADO_PROVA.NU_NOTA END) AS NOTA_PROVA_MT,
		TP_STATUS_REDACAO,
		NU_NOTA_REDACAO,
		PARTICIPANTE.ANO_ENEM,
		MUNICIPIO.NO_MUNICIPIO AS MUNICIPIO_PROVA,
		UNIDADE_FEDERATIVA.NO_UF AS UF_PROVA
	FROM ENEM.RESULTADO_PROVA
	INNER JOIN ENEM.PARTICIPANTE
		ON RESULTADO_PROVA.NU_INSCRICAO = PARTICIPANTE.NU_INSCRICAO
	INNER JOIN ENEM.PROVA
		ON RESULTADO_PROVA.CO_PROVA = PROVA.CO_PROVA
	INNER JOIN ENEM.RESULTADO_REDACAO
		ON RESULTADO_PROVA.NU_INSCRICAO = RESULTADO_REDACAO.NU_INSCRICAO
	INNER JOIN MUNICIPIO
		ON PARTICIPANTE.CO_MUNICIPIO_PROVA = MUNICIPIO.CO_MUNICIPIO
	INNER JOIN REGIAO_GEOGRAFICA_IMEDIATA
		ON MUNICIPIO.CO_RG_IMED = REGIAO_GEOGRAFICA_IMEDIATA.CO_RG_IMED
	INNER JOIN REGIAO_GEOGRAFICA_INTERMEDIARIA
		ON REGIAO_GEOGRAFICA_IMEDIATA.CO_RG_INTERMED = REGIAO_GEOGRAFICA_INTERMEDIARIA.CO_RG_INTERMED
	INNER JOIN UNIDADE_FEDERATIVA
		ON REGIAO_GEOGRAFICA_INTERMEDIARIA.CO_UF = UNIDADE_FEDERATIVA.CO_UF
	GROUP BY RESULTADO_PROVA.NU_INSCRICAO) AS R;


#------------------ PROCEDURE------------------#

DROP PROCEDURE IF EXISTS SITUACAO_PARTICIPANTE;

DELIMITER $$

CREATE PROCEDURE SITUACAO_PARTICIPANTE(
	IN num_inscricao BIGINT
)
proc: BEGIN
	
    DECLARE numero_resultados INT;
    DECLARE numero_faltas INT;
    DECLARE numero_eliminacoes INT;
    DECLARE redacao_status INT;
    
	SELECT COUNT(*) 
    INTO numero_resultados
    FROM ENEM.RESULTADO_PROVA
    WHERE NU_INSCRICAO = num_inscricao;
    
    IF numero_resultados = 0 THEN
		SELECT num_inscricao AS 'NU_INSCRICAO', 
			'UNKNOWN' AS 'STATUS_PARTICIPANTE',
			'Nao foram encontrados resultados para o participante' AS DESCRICAO;
		
        LEAVE proc;
	
    END IF;
    
    SELECT COUNT(*) 
    INTO numero_faltas
    FROM ENEM.RESULTADO_PROVA
    WHERE NU_INSCRICAO = num_inscricao 
		AND TP_PRESENCA = 0;
    
    SELECT COUNT(*) 
    INTO numero_eliminacoes
    FROM ENEM.RESULTADO_PROVA
    WHERE NU_INSCRICAO = num_inscricao 
		AND TP_PRESENCA = 2;
	
    SELECT TP_STATUS_REDACAO
    INTO redacao_status
    FROM ENEM.RESULTADO_REDACAO
    WHERE NU_INSCRICAO = num_inscricao;
    
    IF (numero_faltas = 0) AND (numero_eliminacoes = 0) AND (redacao_status = 1) THEN
		SELECT num_inscricao AS 'NU_INSCRICAO', 
			'OK' AS 'STATUS_PARTICIPANTE',
			'Participante realizou a redacao e todas as provas sem problemas' AS DESCRICAO;
    
    ELSEIF (numero_faltas = 0) AND (numero_eliminacoes = 0) AND (redacao_status IS NULL OR redacao_status != 1) THEN
		SELECT num_inscricao AS 'NU_INSCRICAO', 
			'NOK' AS 'STATUS_PARTICIPANTE',
			'Participante realizou todas as provas, mas apresentou problemas na redacao' AS SITUACAO,
            redacao_status AS 'STATUS_REDACAO';
    
    ELSEIF ((numero_faltas > 0) OR (numero_eliminacoes > 0)) AND (redacao_status = 1) THEN
		SELECT num_inscricao AS 'NU_INSCRICAO', 
			'NOK' AS 'STATUS_PARTICIPANTE',
			'Participante faltou ou foi eliminado(a) de uma ou mais provas. Nao apresentou problemas na redacao' AS SITUACAO,
            numero_faltas AS 'NUMERO_FALTAS',
            numero_eliminacoes AS 'NUMERO_ELIMINACOES';
    
    ELSEIF ((numero_faltas > 0) OR (numero_eliminacoes > 0)) AND (redacao_status IS NULL OR redacao_status != 1) THEN
		SELECT num_inscricao AS 'NU_INSCRICAO', 
			'NOK' AS 'STATUS_PARTICIPANTE',
			'Participante faltou ou foi eliminado(a) de uma ou mais provas. Tambem apresentou problemas na redacao' AS SITUACAO,
            numero_faltas AS 'NUMERO_FALTAS',
            numero_eliminacoes AS 'NUMERO_ELIMINACOES',
            redacao_status AS 'STATUS_REDACAO';
	ELSE
		SELECT num_inscricao AS 'NU_INSCRICAO', 
			'UNKNOWN' AS 'STATUS_PARTICIPANTE',
			'Erro nao esperado. Contate o administrador' AS DESCRICAO;
	
    END IF;
    
END proc$$

DELIMITER ;

#------------------ TRIGGER 1 NOTA PROVA OBJETIVA------------------#

DROP TRIGGER IF EXISTS NOTA_AUSENTE_ELIMINADO;

DELIMITER $$

CREATE TRIGGER NOTA_AUSENTE_ELIMINADO
BEFORE INSERT ON ENEM.RESULTADO_PROVA # Executar antes da insercao do dado
FOR EACH ROW
BEGIN
	# Checar se nota é igual a zero no caso do participante estar ausente ou eliminado
	IF (NEW.TP_PRESENCA != 1) AND (NEW.NU_NOTA != 0) THEN # NEW representa o novo registro a ser inserido
		SIGNAL SQLSTATE '45000' # Excecao definida pelo usuario. Interromper operacao
		SET MESSAGE_TEXT = 'OPERACAO NAO PERMITIDA: Um participante ausente ou eliminado nao pode ter nota diferente de 0. Resultado nao registrado.';
	END IF;

END$$

DELIMITER ;

#------------------ TRIGGER 2 NOTA REDACAO------------------#

DROP TRIGGER IF EXISTS NOTA_STATUS_REDACAO;

DELIMITER $$

CREATE TRIGGER NOTA_STATUS_REDACAO
BEFORE INSERT ON ENEM.RESULTADO_REDACAO # Executar antes da insercao do dado
FOR EACH ROW
BEGIN
	# Checar se nota é igual a zero no caso do participante ter sido eliminado da redacao
	IF (NEW.TP_STATUS_REDACAO != 1) AND (NEW.NU_NOTA_REDACAO != 0) THEN # NEW representa o novo registro a ser inserido
		SIGNAL SQLSTATE '45000' # Excecao definida pelo usuario. Interromper operacao
		SET MESSAGE_TEXT = 'OPERACAO NAO PERMITIDA: Redacoes com status diferente de 1 devem ter nota igual a zero. Resultado nao registrado';
	END IF;
END$$

DELIMITER ;