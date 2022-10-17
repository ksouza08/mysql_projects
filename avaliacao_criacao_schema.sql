
## ------ Avaliacao Banco de Dados -----------##

#######################################
## ----------- AMBIENTE ------------ ##
#######################################

	create schema avaliacao_banco_dados;
	use avaliacao_banco_dados;
    
    create table clientes(
		idCliente int primary key,
        cpf varchar(11) unique,
        nome varchar(100)
         
	);
    
	create table carrinho(
		idCarrinho int primary key,
        idCliente int not null,
        dataCompra datetime,
        constraint foreign key (idCliente) references clientes(idCliente)
	);    

	create table produtos(
		id int primary key,
        nome varchar(30) unique,
		margemLucro float
	);

	create table itens_carrinho(
		idCarrinho int not null,
		idProduto int not null,
		quantidade float,
		valorUnitario float,
		constraint foreign key (idProduto) references produtos(id),
		primary key (idCarrinho,idProduto)
	);
    
    create table compras_itens(
		id int primary key,
        idProduto int not null,
        quantidade float,
        valorUnitario float,
        constraint foreign key (idProduto) references produtos(id)
	);
	
    create table estoque(
		id int primary key,
        idCompras_itens int not null,
        quantidade float,
        entrada datetime,
        constraint foreign key (idCompras_itens) references compras_itens(id)
	);
    
    create table movimentos_estoque(
		idMovimento int primary key auto_increment,
        idEstoque int not null,
        quantidade float,
        in_out varchar(3),
        dataHora datetime,
        observacao varchar(100),
        constraint foreign key (idEstoque) references estoque(id)
	);
    
    drop table log_carrinho;
	create table log_carrinho(
		idLog int primary key auto_increment,
		idCarrinho int default(0),
		datahora datetime,
		descricao varchar(200)
	);
    
    drop view if exists estoque_atual;
	create view estoque_atual as
		select p.id as idProduto, p.nome as produto
				, sum(if(me.in_out = 'IN', me.quantidade, (-me.quantidade))) as estoque 
                , max(e.entrada) as ultimaEntrada
                , avg(ci.valorUnitario) as mediaValorCompra 
                , min(e.id) as idEstoque
			from movimentos_estoque as me
				inner join estoque as e on me.idEstoque = e.id
				inner join compras_itens as ci on e.idCompras_itens = ci.id
                inner join produtos as p on ci.idProduto = p.id
			group by p.nome;
            
	 create view vendas as
        select cli.nome as cliente, c.dataCompra as data, p.nome as produto, ic.quantidade, ic.valorUnitario  from carrinho as c 
			inner join itens_carrinho as ic on c.idCarrinho = ic.idCarrinho
            inner join produtos as p on p.id = ic.idProduto
            inner join clientes as cli on c.idCliente = cli.idCliente;
    



drop schema avaliacao_banco_dados;