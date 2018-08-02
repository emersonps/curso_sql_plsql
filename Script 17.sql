--CAP�TULO 18 - ESCREVENDO CURSORES EXPLICITOS
DECLARE
	vcod_aluno TAluno.cod_aluno%TYPE;  --Inteiro(seleciona a tabela+f12
	vNome		TAluno.nome%TYPE; --Varchar(30)
	CURSOR	c1 IS
	  SELECT 	cod_aluno, nome  --Meu cursor � um select que pega todos os alunos e seus codigos na tabela taluno
	  FROM		taluno;
BEGIN
	OPEN    c1; --Executa como o select criado.
	LOOP --Para percorrer registro por registro.
		FETCH c1 INTO vcod_aluno, vNome;  --Vamos pegar cada registro e jogar nas vari�veis a cada loop.
		EXIT WHEN c1%ROWCOUNT >= 10 OR c1%NOTFOUND;  --O la�o vai parar quando chegar nessa condi��o (quando a quantidade for maior ou igual a 10 ou quando n�o encontrar mais registros no cursor.
    Dbms_Output.Put_Line('Codigo: '|| LPad(vcod_aluno,4,'0') || ' - '||'Nome: '||vNome);
  END LOOP;
  CLOSE c1;
END;
--Obs.: Dessa forma, fica mais aberto a interven��o do la�o. Pois podemos colocar qualquer crit�rio ou regra para terminar o la�o.


--Exemplo 2 - Recuperando todos os registros sem criar vari�veis
DECLARE
  CURSOR c1 IS  --o mesmo cursor
    SELECT * FROM taluno; --pegando todos os dados de taluno.
  Reg c1%ROWTYPE; --record inves de criar vari�vel - o Reg ser� do mesmo tipo do cursor.
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO reg; -- como o Reg tem a mesma estrutura do cursor, pega do Cursor e joga pra dentro do Reg.
    EXIT WHEN c1%ROWCOUNT > 10 OR c1%NOTFOUND; --A mesma regra
    Dbms_Output.Put_Line('Codigo: ' || LPad(reg.cod_aluno,5,'0') || '-' || 'Nome: ' || reg.nome); --Imprimir.
    END LOOP;
    CLOSE c1;
END;

--Obs.: Teremos o mesmo resultado do c�digo anterior. Com a diferen�a que estamos pegando linha por linha do Record e jogando dentro do Cursor.

--Exemplo 3 - Vamos obter o mesmo resultado, mas de forma diferente - A melhor maneira de se fazer um La�o em uma Tabela.
DECLARE
  CURSOR c1 IS
    SELECT * FROM taluno;   --Da mesma forma do cursor do anterior
  Reg taluno%ROWTYPE;
BEGIN
  FOR reg IN c1 --Inves de usar um Loop pra fechar, uso um for. - Essa regra abre o Cursor e Fecha. Esse FOR j� possui a regra %NOTFOUND.
  LOOP
    Dbms_Output.Put_Line('Codigo: ' || LPad(reg.cod_aluno,5,'0') || ' - ' || 'Nome: ' || reg.nome);
  END LOOP;
END;

--Obs.: E melhor maneira de se fazer um la�o em uma tabela.

--Exemplo 4 - Selecionando dados da tabela se usar o Cursor.
DECLARE
  Reg TALUNO%ROWTYPE;
BEGIN
  FOR reg IN (SELECT * FROM TALUNO)
  LOOP
    Dbms_Output.Put_Line('Codigo: ' || LPad(reg.cod_aluno,5,'0')||' - '||'Nome: '||reg.nome);
  END LOOP;
END;

--Obs.: � interessante usar esse modo, quando o SELECT � pequeno, quando n�o tem muitos comandos.

--Exemplo 5 - CURSOR com PAR�METRO - Usar essa maneira se n�o quiser usar o La�o.
DECLARE
  CURSOR c1 (pCod_aluno number) IS --Cursor com o par�metro
    SELECT *
    FROM taluno
    WHERE cod_aluno = pCod_aluno --Usando o cursor, teremos que passar obrigatoriamente esse par�metro.
  FOR UPDATE OF NOME NOWAIT; --Enquanto ele tiver percorrendo o Cursor (select), n�o vou poder alterar a coluna nome.
  --Bloqueia a coluna nome para altera��o - Imagine que o select demore tempo e tenha alguns processos, enquanto isso, a coluna NOME estar� bloqueada pra Update.
  Reg c1%ROWTYPE;
BEGIN
  OPEN c1(&codigo);--Usando a vari�vel de substitui��o para digitar o valor - Abre o cursor e o valor ser� passado como par�metro
  FETCH c1 INTO reg; -- PEga o resultado do cursor e jogar� pra o reg - se n�o encontrar, n�o vai dar erro, as variaveis v�o ficar todas Nulas.
  Dbms_Output.Put_Line('Codigo: '|| LPad(reg.cod_aluno,5,'0')|| ' - '||'Nome: '||reg.nome);
  CLOSE c1; --Libera o registro para altera��o ao fechar.
END;

--Exemplo 6 - For Update
DECLARE
  CURSOR c1 IS
    SELECT nome FROM TALUNO
    FOR UPDATE; --Bloqueando a linha toda.
  Reg_aluno c1%ROWTYPE;
BEGIN
  FOR reg_aluno IN c1
  LOOP
    UPDATE taluno
    SET nome = InitCap(reg_aluno.nome)
    WHERE CURRENT OF c1;  --Cada vez que ele passar pelo registro, ele bloqueia a linha toda-Em caso de outro usuario tentar fazer alguma altera��o, ele ter� que esperar libera��o do la�o.
    Dbms_Output.Put_Line('Nome: '||InitCap(reg_aluno.nome));
  END LOOP;
  COMMIT;
END;

SELECT * FROM TALUNO;

