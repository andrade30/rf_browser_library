*** Settings ***
Resource          ../resources/serve-rest-front.resource
Suite Setup       Cadastrar Usuário e Logar
Suite Teardown    Close Browser  ALL

*** Test Cases ***
Login com sucesso Serve Rest Front
    [Tags]    login    serve_rest_tests
    Abrir o navegador
    Ir para o site Serve Rest Front
    Preencher os dados do novo usuário e cadastrar
    Conferir usuário cadastrado com sucesso

Desafio: Conferir se o novo usuário é mostrado na listagem de usuários
    [Tags]    lista_usuario
    # Cadastrar novo usuário
    Abrir o site Serve Rest Front logado
    Acessar a Lista de usuários
    Conferir que o usuário aparece na listagem de usuários

Desafio: Cadastro e Consulta de produtos
    [Tags]    cad_produto
    # Cadastrar novo usuário
    Abrir o site Serve Rest Front logado
    Cadastrar um novo produto
    Conferir que o produto aparece na listagem de produtos

Exemplo utilizando Requisições HTTP
    [Tags]    http 
    Abrir o navegador
    Ir para o site Serve Rest Front
    Criar usuário via API
    Logar com o usuário cadastrado via API

Exemplo utilizando o Storage Armazenado no Contexto
    [Tags]    storage_contexto
    Abrir o site Serve Rest Front logado
    Acessar a Lista de usuários

    