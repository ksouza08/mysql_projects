
## ------ Avaliacao Banco de Dados -----------##
	use avaliacao_banco_dados;
  
#######################################
## ----------- TRIGGERS ------------ ##
#######################################

## - trigger para moviementação de estoque

	drop trigger if exists trg_entradaEstoque;
    delimiter $$
    create trigger trg_entradaEstoque after insert
    on estoque
    for each row
    begin
		declare qtd float;
        declare msg varchar(50);
        select quantidade into qtd from compras_itens where id = new.idCompras_itens;
        
        call sp_setMovimentoEstoque (new.id, qtd, 'IN', now(),'PRIMEIRA ENTRADA NO ESTOQUE',msg);
		if msg <> '' then
			## Força erro para impedir atualização
			SIGNAL sqlstate '45001' set message_text = msg;
		end if;
        
    end$$
    delimiter ;

## - trigger do historico de inserção no carrinho
	
    drop trigger if exists trg_logEntradaCarrinho;
	delimiter $$            
	create trigger trg_logEntradaCarrinho after insert
	on itens_carrinho
	FOR EACH ROW
	BEGIN
		declare msg varchar(50);
		call sp_removerEstoque(new.idProduto, new.quantidade, msg);
		call sp_setLogMovimentoCarrinho(new.idCarrinho, now(),'out', new.idProduto,new.quantidade);
	END$$
	delimiter ;


## - trigger para verificar o estoque na inserção no carrinho
	
    drop trigger if exists trg_verificarEstoqueEntrada;
	delimiter $$
	create trigger trg_verificarEstoqueEntrada before insert
	on itens_carrinho
	FOR EACH ROW
	BEGIN
		declare ok boolean;
		call sp_verificarEstoque(new.idProduto, new.quantidade, ok);
		if ok = 0 then
			## Força erro para impedir atualização
			SIGNAL sqlstate '45001' set message_text = "Estoque indisponível!";
		end if;
	END$$
	delimiter ;

## - trigger para verificar o estoque na atualização do carrinho
	
    drop trigger if exists trg_verificarEstoqueAtualizacao;
	delimiter $$
	create trigger trg_verificarEstoqueAtualizacao before update
	on itens_carrinho
	FOR EACH ROW
	BEGIN
		declare ok boolean;
		call sp_verificarEstoque(new.idProduto, new.quantidade, ok);
		if ok = 0 then
			## Força erro para impedir atualização
			SIGNAL sqlstate '45001' set message_text = "Estoque indisponível!";
		end if;
	END$$
	delimiter ;
