*** Settings ***
Library    Browser
# ...        timeout=00:00:05
# ...        enable_presenter_mode=${true}
Library    FakerLibrary 
Library    DateTime

*** Variables ***
${BROWSER}                 chromium
${HEADLESS}                ${true}
${URL_SERVE_REST}          https://front.serverest.dev/

*** Keywords ***
Abrir o navegador
    New Browser    browser=${BROWSER}
    ...            headless=${HEADLESS}
    
    ${TRACE_NAME}  FakerLibrary.Uuid 4
    ${NOW}         Get Current Date  result_format=%d-%m-%Y_%H%M%S
    New Context    viewport={'width': 1200, 'height': 800}
    # ...            tracing=${OUTPUT_DIR}/evidencies/traces/${NOW}/${TRACE_NAME}.zip
    # ...            recordVideo={'dir':'${OUTPUT_DIR}/evidencies/videos/${NOW}'}

Ir para o site Serve Rest Front
    New Page       url=${URL_SERVE_REST}
    ${title}       Get Title  ==  Front - ServeRest
    Log    ${title}

Preencher os dados do novo usuário e cadastrar
    #Record  Selector
    # Click    css=.btn-link
    # Click    text=Cadastre-se
    Click       css=a[data-testid='cadastrar']
    ${EMAIL}    FakerLibrary.Email
    Set Test Variable    ${EMAIL}

    Fill Text        css=input[data-testid='nome']        Pedro Vinicius 
    Fill Text        css=input[data-testid='email']       ${EMAIL}
    Fill Text        css=input[data-testid='password']    123456

    Check Checkbox   css=input[data-testid='checkbox']
    # Click            css=button[data-testid='cadastrar']
    Click            xpath=//*[@id="root"]//button >> text="Cadastrar"

Preencher Credenciais
    [Arguments]       ${email}    ${senha}

    Fill Text        css=input[placeholder="Digite seu email"]    ${email}
    Fill Text        css=input[placeholder="Digite sua senha"]    ${senha}
Submeter login
    Click            css=button[data-testid='entrar']
 Cadastrar novo usuário
    Abrir o navegador
    Ir para o site Serve Rest Front
    Preencher os dados do novo usuário e cadastrar
    Conferir usuário cadastrado com sucesso

 Acessar a Lista de usuários
     Click        css=a[data-testid='listarUsuarios']
    #  Get Text  h1 == Lista dos usuários

Cadastrar um novo produto
    Click                css=a[data-testid='cadastrarProdutos']
    ${NOME_PRODUTO}      FakerLibrary.Word
    Set Test Variable    ${NOME_PRODUTO}
    # Get Text     text=Cadastro de Produtos
    Fill Text    css=input[data-testid='nome']                      ${NOME_PRODUTO}
    Fill Text    css=input[data-testid='preco']                     10
    Fill Text    css=textarea[data-testid='descricao']              Ar condicionado
    Fill Text    css=input[data-testid='quantity']                  5
    Click        text="Cadastrar"

Criar usuário via API
    ${EMAIL}    FakerLibrary.Email
    Set Suite Variable    ${EMAIL}

    ${response}    Http    url=https://serverest.dev/usuarios    
    ...                    method=POST 
    ...                    body={"nome": "Alessandro Andrade","email": "${EMAIL}","password": "12345","administrador": "true"}

    Should Be Equal As Integers    ${response["status"]}    201    

Logar com o usuário cadastrado via API
    ${response}    Http    url=https://serverest.dev/login
    ...                    method=POST
    ...                    body={"email": "${EMAIL}","password": "12345"}
    
    Should Be Equal As Integers    ${response["status"]}    200

    LocalStorage Set Item    serverest/userEmail    ${EMAIL}
    LocalStorage Set Item    serverest/userToken    ${response["body"]["authorization"]}
    LocalStorage Set Item    serverest/userNome     Alessandro Andrade 

    Go To    url=https://front.serverest.dev/admin/home

    Take Screenshot

Cadastrar Usuário e Logar
    New Browser    browser=${BROWSER}
    ...            headless=${HEADLESS}
    New Page    url=${URL_SERVE_REST}
    Criar usuário via API
    Logar com o usuário cadastrado via API
    ${STORAGE_FILE}    Save Storage State
    Set Suite Variable    ${STORAGE_FILE}

Abrir o site Serve Rest Front logado
    New Browser
    New Context    viewport={'width': 1200, 'height': 800}
    ...            storageState=${STORAGE_FILE}
    New Page       url=https://front.serverest.dev/admin/home
    Get Text       h1  ==  Bem Vindo Alessandro Andrade
    Take Screenshot

##CONFERÊNCIAS
Conferir usuário cadastrado com sucesso
    Wait For Elements State    h1    visible
    Get Text    h1  ==  Bem Vindo Pedro Vinicius
    Get Element States    css=button[data-testid='logout']    validate    value & visible

Conferir usuário logado com sucesso
    Wait For Elements State    h1    visible    
    Get Text              text=Bem Vindo Pedro Vinicius
    Get Element States    css=button[data-testid='logout']    validate    value & visible

Conferir que o usuário aparece na listagem de usuários
    ${elemento}    Get Table Cell Element     css=table    "Nome"    "${EMAIL}"
    ${user_name}   Get Text  ${elemento}  ==  Alessandro Andrade
    Highlight Elements    ${elemento}
    Take Screenshot       fullPage=${true}

Conferir que o produto aparece na listagem de produtos
    ${elemento}     Get Table Cell Element    css=table    "Descrição"    "${NOME_PRODUTO}"
    ${descricao}    Get Text    ${elemento}    ==    Ar condicionado
    Highlight Elements    ${elemento}
    Take Screenshot       fullPage=${true}
    