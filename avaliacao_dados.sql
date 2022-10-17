## ------ Avaliacao Banco de Dados -----------##
	use avaliacao_banco_dados;

## Preencher tabelas
## CLIENTES
	insert into clientes (idCliente, cpf, nome) values (1,'12345678910','Jose da Silva'),
		(2,'32145678910','Joao Carlos'),
		(3,'12355578910','Marcos Rodrigues'),
		(4,'12345612310','Ana Cristina'),
		(5,'12233568741','Ana Carolina'),
		(6,'10987654321','Jonas Souza'),
		(7,'65432178910','Maria Helena'),
		(8,'58245678910','Rosana Castro'),
		(9,'23145678913','Ana Rosa'),
		(10,'32146578911','Mariana Souza');

## PRODUTOS
	insert into produtos (id,nome, margemLucro) values
    (1,'Arroz Streck 5kg',	0.15),
	(2,'Arroz Streck 2kg',	0.15),
	(3,'Feijão Tarumã 1kg',	0.15),
	(4,'Feijão Tarumã 2kg',	0.15),
	(5,'Margarina Doriana 250g',	0.15),
	(6,'Margarina Qualy 500g',	0.15),
	(7,'Sal Cisne 1kg',	0.15),
	(8,'Pó Café Pilão 500g',	0.15),
	(9,'Leite Italac Integral 1L',	0.15),
	(10,'Leite Camponesa Integral 1L',	0.15);

## CARRINHO
	
	insert into carrinho(idCarrinho,dataCompra, idCliente) values (1,timestampadd(day,-(RAND()*(20-5+1)),now()),1);
	insert into carrinho(idCarrinho,dataCompra, idCliente) values (2,timestampadd(day,-(RAND()*(20-5+1)),now()),2);
	insert into carrinho(idCarrinho,dataCompra, idCliente) values (3,timestampadd(day,-(RAND()*(20-5+1)),now()),3);
	insert into carrinho(idCarrinho,dataCompra, idCliente) values (4,timestampadd(day,-(RAND()*(20-5+1)),now()),4);
	insert into carrinho(idCarrinho,dataCompra, idCliente) values (5,timestampadd(day,-(RAND()*(20-5+1)),now()),4);
	insert into carrinho(idCarrinho,dataCompra, idCliente) values (6,timestampadd(day,-(RAND()*(20-5+1)),now()),4);
	insert into carrinho(idCarrinho,dataCompra, idCliente) values (7,timestampadd(day,-(RAND()*(20-5+1)),now()),5);
	insert into carrinho(idCarrinho,dataCompra, idCliente) values (8,timestampadd(day,-(RAND()*(20-5+1)),now()),7);
	insert into carrinho(idCarrinho,dataCompra, idCliente) values (9,timestampadd(day,-(RAND()*(20-5+1)),now()),1);
	insert into carrinho(idCarrinho,dataCompra, idCliente) values (10,timestampadd(day,-(RAND()*(20-5+1)),now()),9);
	insert into carrinho(idCarrinho,dataCompra, idCliente) values (11,timestampadd(day,-(RAND()*(20-5+1)),now()),1);
    
    select * from carrinho;
    
## COMPRAS_ITENS
	
    insert into compras_itens(id,idProduto,quantidade,valorUnitario) Values (1,2,30,19);
    insert into compras_itens(id,idProduto,quantidade,valorUnitario) Values (2,3,20,10);
    insert into compras_itens(id,idProduto,quantidade,valorUnitario) Values (3,4,40,3.5);
    insert into compras_itens(id,idProduto,quantidade,valorUnitario) Values (4,10,50,5);
    insert into compras_itens(id,idProduto,quantidade,valorUnitario) Values (5,5,60,8);
    insert into compras_itens(id,idProduto,quantidade,valorUnitario) Values (6,7,20,5);
    insert into compras_itens(id,idProduto,quantidade,valorUnitario) Values (7,6,15,3);
    insert into compras_itens(id,idProduto,quantidade,valorUnitario) Values (8,9,30,18);
    insert into compras_itens(id,idProduto,quantidade,valorUnitario) Values (9,10,60,5);
    insert into compras_itens(id,idProduto,quantidade,valorUnitario) Values (10,9,60,6.5);
    
    select * from compras_itens;

## ESTOQUE
	call sp_setEntradaTotalCompra(10);
	call sp_setEntradaTotalCompra(9);
	call sp_setEntradaTotalCompra(8);
	call sp_setEntradaTotalCompra(7);
	call sp_setEntradaTotalCompra(6);
	call sp_setEntradaTotalCompra(5);
	call sp_setEntradaTotalCompra(4);
	call sp_setEntradaTotalCompra(3);
	call sp_setEntradaTotalCompra(2);
	call sp_setEntradaTotalCompra(1);
      
    select * from estoque;
    select * from movimentos_estoque;
    
    delete from movimentos_estoque;
    delete from estoque;
    

## cadastrando clientes
	call sp_novoCliente('Mariana Ferreira','32146578910');
	call sp_alterarCliente('32146578910', 'Mariana Santos');
	call sp_removerCliente('32146578910');
    call sp_novoCliente('Mariana Souza','32146578911');
	
	select * from clientes;
  #delete from clientes;
  
## - Manipulando Produtos
	
	call sp_novoProduto('Leite Camponesa Integral 1L',0.15);
    call sp_alterarProduto(10,'Leite Camponesa Desnatado 1L',0.14);
    call sp_alterarProduto(10,'Leite Camponesa Integral 1L',0.16);
    call sp_removerProduto(10);
    
    select * from Produtos;
	delete from produtos where id = 1;

## Manipulação de compras

	call sp_novaCompra(10,50,18);
	call sp_alterarCompra(8,09,50,6);
	call sp_removerCompra(11);
    
    select * from compras_itens;

## Manipulação de estoque
	
    call sp_setItemCarrinho(1,2,8);
    call sp_setItemCarrinho(1,4,4);
    call sp_setItemCarrinho(1,5,9);
    call sp_setItemCarrinho(4,5,9);
    call sp_setItemCarrinho(6,5,9);
    call sp_setItemCarrinho(2,5,9);
    call sp_setItemCarrinho(3,8,9);
    call sp_setItemCarrinho(3,4,9);
    call sp_setItemCarrinho(3,2,9);
    call sp_setItemCarrinho(5,5,9);
    
    select * from itens_carrinho;
    select * from log_carrinho;
	