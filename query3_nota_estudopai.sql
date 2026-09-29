SELECT RESPOSTA, ROUND(AVG(NOTA_FINAL),2) AS NOTA_MEDIA FROM ( # Calcular a nota média dos participantes agrupados pelo nível de estudo do pai
	SELECT RR.NU_INSCRICAO, ((NU_NOTA_REDACAO + SOMA_NOTAS) / 5) AS NOTA_FINAL, # Selecionar nota final do participante com base na redacao e nas provas
    RQ.COD_QUESTAO, RQ.RESPOSTA # Selecionar codigo das questoes e as respectivas respostas
    FROM ENEM.RESULTADO_REDACAO RR
	INNER JOIN ( # JOIN com tabela referente a soma das notas das provas objetivas
		SELECT NU_INSCRICAO, SUM(NU_NOTA) AS SOMA_NOTAS # Query para resgatar soma das provas objetivas por participante
        FROM ENEM.RESULTADO_PROVA
		GROUP BY NU_INSCRICAO # Agrupar por participante
        ) RP # Tabela com a soma das notas das provas objetivas dos participantes
	ON RR.NU_INSCRICAO = RP.NU_INSCRICAO
	INNER JOIN RESPOSTA_QUESTIONARIO RQ ON RP.NU_INSCRICAO = RQ.NU_INSCRICAO # JOIN com a tabela das respostas do questionario
	WHERE RQ.COD_QUESTAO = 'Q001' # Filtrar apenas para a primeira questao do questionario
    ) NOTA_FINAL_RESPOSTA # Tabela com nota final e resposta da Q001 por participante
GROUP BY RESPOSTA # Agrupar por resposta (nivel de estudo do pai)
ORDER BY RESPOSTA ASC; # Ordenar por tipo de resposta