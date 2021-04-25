**SUEL AUDITORIA FIVEM**

# COMO INSTALAR

1. Faça o download desse resource e coloque na sua pasta de resource;
2. Abra o arquivo fxmanifest.lua, procure pela tag discord_webhook '', coloque seu webhook entre as ' ';
3. Adicione ensure nome_do_resource na lista de resource do seu servidor;
4. Configure as permissões ACE se quiser usar o comando no jogo;

# COMO USAR

1. Se quiser habilitar o comando para ser executado no jogo coloque a seguinte permissão ACE: **add_ace sua.licença "command.auditar" allow**
2. No terminal ou no chat execute o comando **auditar saida tipo id** dessa forma será enviado os logs para o discord, através do webhook que você definiu no fxmanifest, ou **auditar d p 1** será mostrada apenas no terminal no lado do servidor as informações.
# LISTA DE ARGUMENTOS ACEITOS

Primeiro argumento: \[**SAIDA**\]

Descrição: Especifica a saída, se vai mostrar no terminal ou enviar para o discord.

**d**: enviar para o discord
**c**: mostra no terminal (usada apenas para debug, não é formatado)

Segundo argumento: \[**TIPO**\]

Descrição: Especifica o tipo de log, sendo para jogador ou grupos

**p**: especifica que se deseja log sobre o jogador
**f**: especifica que se deseja log sobre grupo/facções

Terceiro argumento: \[**ID-GRUPO**\]

Descrição: especifica o id ou o nome do grupo que se deseja obter informações

**ID** do jogador se o segundo argumento for **p**; ou
**NOME_DO_GRUPO** da fação se o segundo argumento for **f**.




**[Visualização](https://youtu.be/eIBOKBLABR8)**
