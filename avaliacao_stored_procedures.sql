
## ------ Avaliacao Banco de Dados -----------##
	use avaliacao_banco_dados;
  
#######################################
## ------ STORED PROCEDURES -------- ##
#######################################

## - STP para validacao de cliente
	drop procedure if exists sp_validarCliente;
	delimiter $$
	create procedure sp_validarCliente(in nomeCli varchar(105), in cpfCli varchar(12), out msg varchar(200))
	begin
		if length(nomeCli) < 5 or length(nomeCli) > 100 then
			set msg = 'Nome deve conter entre 5 e 100 caracteres';
		elseif length(cpfCli) <> 11 then
			set msg = 'cpf deve conter apenas 11 caracteres numericos';
		else
			set msg = '';
		end if; 
    end $$    
    delimiter ;
    
## - STP para cadastrar cliente
	drop procedure if exists sp_novoCliente;
	delimiter $$
	create procedure sp_novoCliente(in nomeCli varchar(105), in cpfCli varchar(12))
	begin
		declare msg varchar(200);
        declare ultimoId int;
        
        select ifnull(max(idCliente),0) + 1 into ultimoId from clientes;
        
        call sp_validarCliente(nomeCli, cpfCli, msg);
        
        if msg = '' then
        	insert into clientes(idCliente, nome,cpf) values (ultimoId,nomeCli, cpfCli);
			set msg = concat('Cadastrado: Cliente: ',nomeCli,' - CPF: ', cpfCli);
		end if;
        select msg;       
    end $$    
    delimiter ;

## - STP para alterar cliente
	drop procedure if exists sp_alterarCliente;
	delimiter $$
	create procedure sp_alterarCliente(in cpfCli varchar(12), in novoNomeCli varchar(105))
	begin
		declare msg varchar(200);
        call sp_validarCliente(novoNomeCli, cpfCli, msg);
        if msg = '' then
        	update clientes set nome = novoNomeCli where cpf = cpfCli;
			set msg = concat('Atualizado: Cliente: ',novoNomeCli,' - CPF: ', cpfCli);
		end if;
        select msg;       
    end $$    
    delimiter ;
    
## - STP para remover cliente
	drop procedure if exists sp_removerCliente;
	delimiter $$
	create procedure sp_removerCliente(in cpfCli varchar(12))
	begin
		declare msg varchar(200);
        if length(cpfCli) <> 11 then
			set msg = 'cpf deve conter apenas 11 caracteres numericos';
        else
        	delete from clientes where cpf = cpfCli;
			set msg = concat('Removido cliente: CPF: ', cpfCli);
		end if;
        select msg;       
    end $$    
    delimiter ;

    
## - STP para adicionar produto	
    drop procedure if exists sp_novoProduto;
    delimiter $$
    create procedure sp_novoProduto(in nomeProd varchar(40), in margem float)
    begin
		declare msg varchar(200);
        declare ultimoId int;
        
        select ifnull(max(id),0) + 1 into ultimoId from produtos;
        
        if length(nomeProd) < 3 or length(nomeProd) > 30 then
			set msg = 'Nome produto deve conter entre 3 e 30 caracteres';
		elseif margem < 0 then
			set msg = 'margem deve ser maior ou igual 0';
		else
			insert into produtos(id,nome, margemLucro) values (ultimoId, nomeProd, margem);
            set msg = concat('Inserido produto: ', nomeProd, ' - margem: ', margem, ' %');
		end if;
        select msg;
    end $$
    delimiter ;
    
    ## - STP para alterar produto	
    drop procedure if exists sp_alterarProduto;
    delimiter $$
    create procedure sp_alterarProduto(in idProd int, in novoNomeProd varchar(40), in novaMargem float)
    begin
		declare msg varchar(200);
        declare nomeAtual varchar(30);
        
        select nome into nomeAtual from produtos where id = idProd;
                
        if (length(novoNomeProd) < 3 or length(novoNomeProd) > 30) and novoNomeProd <> '' then
			set msg = 'Nome produto deve conter entre 3 e 30 caracteres';		
		elseif novaMargem < 0 then
			set msg = 'margem deve ser maior ou igual 0';
		elseif nomeAtual is null then
			set msg = 'não encontrado';
        else
            update produtos set nome = if(novoNomeProd = '',nomeAtual, novoNomeProd),								
                                margemLucro = novaMargem
					where id = idProd;
            set msg = concat('Produto atualizado: ', novoNomeProd, ' - margem: ', novaMargem, ' %');            
		end if;
        select msg;
    end $$
    delimiter ;

	## - STP para remover produto	
    drop procedure if exists sp_removerProduto;
    delimiter $$
    create procedure sp_removerProduto(in idProd int)
    begin
		declare msg varchar(200);
        declare pendencias long;
       
       if (select count(*) from produtos where id = idProd) > 0 then 
			set pendencias  = (select count(ic.idProduto) from itens_carrinho as ic where ic.idProduto = idProd);		
			set pendencias  = pendencias + (select count(ci.idProduto) from compras_itens as ci where ci.idProduto = idProd);		
			if pendencias = 0 then
				delete from produtos where id = idProd;
				set msg = concat('Removido produto id: ', idProd);
			else
				set msg = 'Não removido! Este produto contem vendas ou compras vinculadas!';
			end if;
		else
			set msg = 'não encontrado';
        end if;
        select msg;        
    end $$
    delimiter ;

## - STP para inserir nova compra
	
    drop procedure if exists sp_novaCompra;
	delimiter $$
    create procedure sp_novaCompra(in idProd int, in qtd float, in valor float)
    begin
		declare msg varchar (200);
         declare ultimoId int;
        
        select ifnull(max(id),0) + 1 into ultimoId from compras_itens;
                
        if not((select count(*) from produtos where id = idProd) > 0) then
			set msg = 'produto nao encontrado!';
		elseif not(qtd > 0) then 
			set msg = 'quantidade deve ser maior que zero!';
		elseif not(valor > 0) then 
			set msg = 'valor deve ser maior que zero!';
		else       
			insert into compras_itens (id,idProduto, quantidade, valorUnitario)
						values (ultimoId,idProd, qtd, valor);
			set msg = 'Compra criada!'; 
		end if;
        select msg;
    end $$
    delimiter ;
    
	
## - STP para alterar compra
	drop procedure if exists sp_alterarCompra;
	delimiter $$
    create procedure sp_alterarCompra(in idCompra int, in idProd int, in qtd float, in valor float)
    begin
		declare msg varchar(200);
        if (select count(*) from estoque where idCompras_itens = idCompra) > 0 then
			set msg = 'Não Alterada! Esta compra possui histórico de movimentação';
		elseif not((select count(*) from produtos where id = idProd) > 0) then
			set msg = 'Não Alterada! Produto nao existe';
		elseif not(qtd > 0) then 
			set msg = 'Não Alterada! quantidade deve ser maior que zero!';
		elseif not(valor > 0) then 
			set msg = 'Não Alterada! valor deve ser maior que zero!';
		else
			update compras_itens set idProduto = idProd,
									  quantidade = qtd,
                                      valorUnitario = valor
					where id = idCompra;
			set msg = 'Compra Alterada!'; 
		end if;
        select msg;
    end $$
    delimiter ;
    

## - STP para remover compra
	drop procedure if exists sp_removerCompra;
    delimiter $$
    create procedure sp_removerCompra(in idCompra int)
    begin
		declare msg varchar (200);
        declare pendencias long;
        
        if (select count(*) from estoque where idCompras_itens = idCompra) > 0 then
			set msg = 'Não removida! Esta compra possui histórico de movimentação';
		else
			delete from compras_itens where id = idCompra;
            set msg = concat('Removida compra id: ', idCompra);
		end if;
        select msg;        
    end $$
    delimiter ;


## - STP para entrada de compra
	drop procedure if exists sp_setEntradaTotalCompra;
    delimiter $$
    create procedure sp_setEntradaTotalCompra(in idCompra int)
    begin
		declare msg varchar (200);
        declare ultimoId int;
        declare qtd float;       
        
        if not((select count(*) from compras_itens where id = idCompra) > 0) then
			set msg = 'Compra nao encontrada';
		else        
			select ifnull(max(id),0) + 1 into ultimoId from estoque;
			select quantidade into qtd from compras_itens where id = idCompra;
			insert into estoque(id,idCompras_itens,quantidade,entrada) 
				values (ultimoId,idCompra,qtd,now());
			
            set msg = concat('Entrada efetuada para compra id: ', idCompra);
		end if;
        select msg;
    end $$
    delimiter ;
	



## - STP para inserir log de movimentos de entrada e saida de estoque

	drop procedure if exists sp_setMovimentoEstoque;
	delimiter $$
	create procedure sp_setMovimentoEstoque(in idEstoque int, in qtd float, in in_out varchar(3), in dtMovimento datetime , in obs varchar(100), out msg varchar(50)) 
	begin
		set msg = '';
		if not((select count(*) from estoque where id = idEstoque) > 0) then
			set msg = 'estoque nao encontrado';
		elseif not((select quantidade from estoque where id = idEstoque) > 0) then
			set msg = 'estoque zerado para compra';
		else
			insert into movimentos_estoque (idEstoque,quantidade,in_out,dataHora,observacao)
				values (idEstoque, qtd, in_out, dtMovimento,obs);
			set msg = '';
		end if;
		
	end$$
	delimiter ;

## - STP para inserir log de movimentos de entrada e saida de estoque

	drop procedure if exists sp_removerEstoque;
	delimiter $$
	create procedure sp_removerEstoque(in idProd int, in qtd float, out msg varchar(50)) 
	begin
		declare idEstq int;
        
        select idEstoque into idEstq from estoque_atual where idProduto = idProd;
        
		call sp_setMovimentoEstoque (idEstq, qtd, 'OUT', now(), 'Saida por venda', msg);
		
		
	end$$
	delimiter ;
	
    select estoque from estoque_atual where idProduto = 2;
    
## - STP para verificar se o estoque possui quantidade disponivel	            
    drop procedure if exists sp_verificarEstoque;
	delimiter $$
	create procedure sp_verificarEstoque(in idProd int, in qtd float, out ok boolean)
	begin
		declare tmp float;
        
		select estoque into tmp from estoque_atual where idProduto = idProd;
                
		if tmp >= qtd and tmp > 0 then
			set ok = 1;
		else
			set ok = 0;
		end if;    
	end$$
	delimiter ;


## - STP adicionar item carrinho
	drop procedure if exists sp_setItemCarrinho;
	delimiter $$
	create procedure sp_setItemCarrinho(in idcarr int ,in idProd int, in qtd float)
	begin
		
        declare valor float;
        declare ok boolean;
        declare msg varchar(50);
                
        call sp_verificarEstoque(idProd, qtd, ok);
		
        if ok = 1 then
			select mediaValorCompra into valor from estoque_atual where idProduto = idProd;
			insert into itens_carrinho(idCarrinho,idProduto,quantidade, valorUnitario) values	(idcarr,idProd , qtd , valor);
			set msg = 'item inserido';
		else
			set msg = 'erro';
		end if;
        select msg;
  
	end $$
	delimiter ;
    
    
    ## - STP para inserir log de movimentos de entrada e saida de estoque

	drop procedure if exists sp_setLogMovimentoCarrinho;
	delimiter $$
	create procedure sp_setLogMovimentoCarrinho(in idCarrinho int, in dtMovimento datetime, in in_out varchar(3), in idProd int, in qtd float) 
	begin
		declare msg varchar(50);
		set msg = '';
		if upper(in_out) = 'IN' then
			insert into log_carrinho(idCarrinho,datahora,descricao)
			values (idCarrinho, now(), concat('ENTRADA DE ESTOQUE| ID Produto: ',idProd,' | QTD:' , qtd));
		elseif upper(in_out) = 'OUT' then
			insert into log_carrinho(idCarrinho,datahora,descricao)
				values (idCarrinho, now(), concat('SAÍDA DE ESTOQUE| ID Produto: ',idProd,' | QTD:' , qtd));
		end if;
	end$$
	delimiter ;
    
    
    