.data
    # Mensagens do menu e prompts
    menuPrincipal: .asciiz "\n=== SEJA BEM VINDO À FEIRA! ===\n1. Iniciar compra\n2. Sair\nEscolha uma opcao: "
    prompt_qtd_items: .asciiz "\nQuantos items diferentes deseja comprar (1-20)? "
    itensDisp: .asciiz "\nPRODUTOS DISPONIVEIS (PRECO POR KG):\n1. Abacaxi R$ 5.00\n2. Banana R$ 3.50\n3. Maca R$ 4.00\n4. Manga R$ 4.50\n5. Laranja R$ 3.00\n6. Melancia R$ 2.50\n7. Morango R$ 15.00\n8. Tomate R$ 6.00\n9. Alface R$ 2.50\n10. Couve R$ 3.00\n11. Cenoura R$ 3.50\n12. Beterraba R$ 4.00\n13. Abobora R$ 3.80\n14. Batata-doce R$ 3.50\n15. Pimentao R$ 7.00\n16. Quiabo R$ 8.00\n17. Berinjela R$ 5.50\n18. Abobrinha R$ 4.50\n19. Goiaba R$ 6.00\n20. Rucula R$ 4.00\n"
    prompt_id: .asciiz "\nDigite o ID do produto (1-20): "
    prompt_kg: .asciiz "Digite a quantidade em KG: "
    prompt_pagamento: .asciiz "\n\nValor total da feira: R$ "
    pagamento_inserido: .asciiz "\nInsira o valor pago: R$ "
    troco_msg: .asciiz "\nTroco: R$ "
    valor_parcial: .asciiz "\nSubtotal atual: R$ "
    erro_msg: .asciiz "\nValor insuficiente! Tente novamente."
    id_invalido: .asciiz "\nID invalido!\n"
    qtd_invalida: .asciiz "\nQuantidade invalida! Digite novamente.\n"

    # Arrays com informacoes dos produtos
    ids: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20
    precos: .float 5.00, 3.50, 4.00, 4.50, 3.00, 2.50, 15.00, 6.00, 2.50, 3.00, 3.50, 4.00, 3.80, 3.50, 7.00, 8.00, 5.50, 4.50, 6.00, 4.00
    nomes: .asciiz "Abacaxi", "Banana", "Maca", "Manga", "Laranja", "Melancia", "Morango", "Tomate", "Alface", "Couve", "Cenoura", "Beterraba", "Abobora", "Batata-doce", "Pimentao", "Quiabo", "Berinjela", "Abobrinha", "Goiaba", "Rucula"

    ids_carrinho: .word 0:20 # ID de cada item no carrinho
    qtds_carrinho: .float 0:20  # Quantidade de cada item no carrinho
    tam_carrinho: .word 0  # Quantidade de itens no carrinho

    # Nota fiscal
    nota: .asciiz "\n=================================================\n                NOTA FISCAL ELETRÔNICA\n=================================================\n"
    fim_nota: .asciiz "-------------------------------------------------\n"
    preco_total: .asciiz "TOTAL: "
    espaco: .asciiz " "
    espacos_10: .asciiz "          "
    espacos_6: .asciiz "      "
    proxLinha: .asciiz "\n"
    voltarMenu: .asciiz "\nDeseja processar outra compra? (1 - Sim, 2 - Nao): "
    colunas: .asciiz "ID Produto       KG         Preco/KG        Total\n-------------------------------------------------\n"
    real: .asciiz "R$ "
    kg: .asciiz " kg"

    n_100: .float 100.0 
    zero_float: .float 0.0
    total_valor: .float 0.0

.text
.globl main

main:
    # Exibe menu principal e processa escolha
    li $v0, 4
    la $a0, menuPrincipal
    syscall
    li $v0, 5
    syscall
    beq $v0, 1, iniciar_compra
    beq $v0, 2, sair
    j main

iniciar_compra:
    # Inicializa carrinho vazio
    sw $zero, tam_carrinho
    # Mostra produtos disponiveis
    li $v0, 4
    la $a0, itensDisp
    syscall
    # Pergunta quantidade de itens diferentes
    li $v0, 4
    la $a0, prompt_qtd_items
    syscall
    li $v0, 5
    syscall
    # Valida quantidade
    blez $v0, qtd_invalida_erro
    li $t7, 20
    bgt $v0, $t7, qtd_invalida_erro
    move $s0, $v0  # Salva quantidade total de itens
    li $s1, 0      # Contador de itens inseridos

loop_inserir_items:
    beq $s1, $s0, terminar_compra
    
receber_id:
    # Le e valida ID
    li $v0, 4
    la $a0, prompt_id
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    blez $t0, id_invalido_erro
    li $t7, 20
    bgt $t0, $t7, id_invalido_erro
    # Le quantidade em KG
    li $v0, 4
    la $a0, prompt_kg
    syscall
    li $v0, 6    
    syscall
    # Armazena no carrinho
    lw $t2, tam_carrinho
    la $t3, ids_carrinho
    la $t4, qtds_carrinho
    sll $t5, $t2, 2   # Desloca o valor em $t4 para a esquerda em 2 bits (equivalente a multiplicar por 4). Necessario ara acessar um elemento em um array.
    add $t3, $t3, $t5
    add $t4, $t4, $t5
    addi $t0, $t0, -1    # Ajusta os IDs para comecar em zero -> ID = ID - 1
    sw $t0, ($t3)        # Salva ID
    swc1 $f0, ($t4)      # Salva quantidade em kg   
    # Atualiza contadores
    addi $s1, $s1, 1
    addi $t2, $t2, 1
    sw $t2, tam_carrinho
    # Mostra valor parcial
    jal calcular_total
    li $v0, 4
    la $a0, valor_parcial
    syscall
    li $v0, 2
    lwc1 $f12, total_valor
    syscall
    j loop_inserir_items

qtd_invalida_erro:
    # Exibe erro de quantidade invalida
    li $v0, 4
    la $a0, qtd_invalida
    syscall
    j iniciar_compra

id_invalido_erro:
    # Exibe erro de ID invalido
    li $v0, 4
    la $a0, id_invalido
    syscall
    j receber_id

terminar_compra:
    jal calcular_total
    j pagamento_loop

calcular_total:
    # Inicializa total como zero
    l.s $f4, zero_float
    swc1 $f4, total_valor
    lw $t0, tam_carrinho
    li $t1, 0

loop_calc:
    beq $t1, $t0, fim_contas # Se a quantidade de itens desejada for atigida, parar a conta  
    # Carrega ID e quantidade
    la $t2, ids_carrinho
    la $t5, qtds_carrinho
    sll $t3, $t1, 2
    add $t2, $t2, $t3
    add $t5, $t5, $t3
    lw $t4, ($t2)
    lwc1 $f6, ($t5) # Carrega quantidade por kg do item
    # Busca preco
    sll $t4, $t4, 2
    la $t7, precos
    add $t7, $t7, $t4
    lwc1 $f8, ($t7)  # Carrega o preco por kg do item
    # Multiplica preco por kg
    mul.s $f10, $f8, $f6
    # Arredonda para duas casas decimais
    l.s $f5, n_100  
    mul.s $f10, $f10, $f5 
    round.w.s $f10, $f10
    cvt.s.w $f10, $f10
    div.s $f10, $f10, $f5
    # Adiciona ao total
    lwc1 $f4, total_valor
    add.s $f4, $f4, $f10
    swc1 $f4, total_valor
    addi $t1, $t1, 1 
    j loop_calc

fim_contas:
    jr $ra

pagamento_loop:
    # Processa pagamento e calcula troco
    li $v0, 4
    la $a0, prompt_pagamento
    syscall
    li $v0, 2
    lwc1 $f12, total_valor
    syscall
    li $v0, 4
    la $a0, pagamento_inserido
    syscall
    li $v0, 6
    syscall
    lwc1 $f2, total_valor
    # Se o valor pago for inferior ao valor final, mostrar erro
    c.lt.s $f0, $f2
    bc1t pagamento_erro
    sub.s $f12, $f0, $f2  # Subtrai o valor total pelo valor pago para obter o troco
    # imprime troco
    li $v0, 4
    la $a0, troco_msg
    syscall
    li $v0, 2
    syscall
    jal imprimir_nota
    j voltar_ao_menu

pagamento_erro:
    # Exibe erro de pagamento insuficiente
    li $v0, 4
    la $a0, erro_msg
    syscall
    j pagamento_loop

imprimir_nota:
    # Imprime cabecalho da nota
    li $v0, 4
    la $a0, nota
    syscall
    la $a0, colunas
    syscall
    lw $t0, tam_carrinho
    li $t1, 0

loop_impressao_itens:
    beq $t1, $t0, imprimir_total # Se a quantidade de itens comprados for atigida, parar a impressao
    # Carrega ID e quantidade
    la $t2, ids_carrinho
    la $t3, qtds_carrinho
    sll $t4, $t1, 2
    add $t2, $t2, $t4
    add $t3, $t3, $t4
    lw $t5, ($t2)
    lwc1 $f6, ($t3)   # Carrega ID do item
    # Imprime ID
    addi $t5, $t5, 1
    li $v0, 1
    move $a0, $t5
    syscall
    li $v0, 4
    la $a0, espaco
    syscall
    # Imprime nome do produto
    move $t8, $t5
    addi $t8, $t8, -1
    la $a0, nomes
    
encontrar_nome_loop:
    beqz $t8, imprimir_nome
    lb $t9, ($a0)
    beqz $t9, prox_nome
    addi $a0, $a0, 1
    j encontrar_nome_loop

prox_nome:
    addi $a0, $a0, 1
    addi $t8, $t8, -1
    j encontrar_nome_loop

imprimir_nome:
    # Imprime nome e formatacao
    li $v0, 4
    syscall
    li $v0, 4
    la $a0, espacos_10
    syscall
    # Imprime quantidade em kg
    li $v0, 2
    mov.s $f12, $f6
    syscall
    li $v0, 4
    la $a0, kg
    syscall
    la $a0, espacos_6
    syscall
    # Imprime preco por kg
    la $a0, real
    syscall
    addi $t5, $t5, -1
    sll $t5, $t5, 2
    la $t7, precos
    add $t7, $t7, $t5
    lwc1 $f12, ($t7) # Carrega a quantidade em kg do item
    li $v0, 2
    syscall
    # Imprime total do item
    li $v0, 4
    la $a0, espacos_6
    syscall
    la $a0, real
    syscall
    mul.s $f12, $f12, $f6  # preço por kg * quantidade em kg
    li $v0, 2
    syscall
    
    li $v0, 4
    la $a0, proxLinha
    syscall
    addi $t1, $t1, 1  
    j loop_impressao_itens

imprimir_total:
    # Imprime valor total da compra
    li $v0, 4
    la $a0, fim_nota
    syscall
    la $a0, preco_total
    syscall
    la $a0, real
    syscall
    li $v0, 2
    lwc1 $f12, total_valor  # Carrega o valor total da compra
    syscall
    li $v0, 4
    la $a0, proxLinha
    syscall
    jr $ra

voltar_ao_menu:
    # Pergunta se deseja voltar ao menu
    li $v0, 4
    la $a0, voltarMenu
    syscall
    li $v0, 5
    syscall
    beq $v0, 1, main
    j sair

sair:
    li $v0, 10
    syscall
