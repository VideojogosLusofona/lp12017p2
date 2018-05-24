<!--
2º Projeto de Linguagens de Programação I 2017/2018 (c) by Nuno Fachada

2º Projeto de Linguagens de Programação I 2017/2018 is licensed under a
Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.

You should have received a copy of the license along with this
work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
-->

# 2º Projeto de Linguagens de Programação I 2017/2018

## Descrição do problema

Os alunos devem implementar um jogo _roguelike_ em C# com níveis
[gerados procedimentalmente][GP] em grelhas 8x8. O jogador começa no lado
esquerdo da grelha (1ª coluna), e o seu objetivo é encontrar a saída do nível,
que se encontra do lado direito dessa mesma grelha (8ª coluna). Pelo meio o
jogador pode encontrar NPCs (agressivos ou neutros), encontrar itens (comida,
ouro, armas, mapas), possivelmente apanhando-os, e cair em armadilhas.

Os níveis vão ficando progressivamente mais difíceis, com mais monstros, mais
armadilhas e menos itens. O _score_ final do jogador é igual ao nível atingido,
existindo uma tabela dos top 10 _high scores_, que deve persistir quando o
programa termina e o PC é desligado.

No início de cada nível, o jogador só tem conhecimento da sua vizinhança (de
[Von Neumann][]). À medida que o jogador se desloca, o mapa vai-se revelando. O
jogador só pode deslocar-se na sua vizinhança de [Von Neumann][] usando as
teclas WASD (não usar _keypad_, pois o mesmo não existe em alguns portáteis,
dificultando a avaliação do jogo).

### Modo de funcionamento

O jogo começa por apresentar o menu principal ao utilizador, que deve conter as
seguintes opções:

1.  New game
2.  High scores
3.  Credits
4.  Quit

Caso o utilizador selecione as opções 2 ou 3, é mostrada a informação
solicitada; o utilizador pressiona ENTER (ou qualquer tecla) para continuar,
voltando ao menu principal. A opção 4 termina o programa. Se for selecionada a
opção 1, começa um novo jogo.

As ações disponíveis em cada _turn_ são as seguintes:

* `WSAD` para movimento.
* `F` para atacar um NPC no _tile_ atual.
* `T` para negociar com um NPC no _tile_ atual.
* `E` para apanhar um item no _tile_ atual.
* `U`, seguido de um número de item, para usar um item (arma ou comida), ou 0
  para voltar atrás.
  * No caso de uma arma, a mesma é equipada (selecionada para combate). Caso
    exista uma arma equipada anteriormente, a mesma passa para o inventário.
  * No caso de comida, a mesma é consumida, aumentando o HP na proporção
    especificada para a comida em questão, até um máximo de 100.
* `D`, seguido do número do item, para largar o item no _tile atual_ (arma,
  comida ou ouro), ou 0 para voltar atrás. No caso do ouro, solicitar ao
  utilizador a quantidade a largar no local.
* `Q` para terminar o jogo.

Em cada _turn_ é consumido automaticamente 1 HP do jogador, independentemente
da ação realizada.

#### Personagens

Os diferentes personagens do jogo (jogador e NPCs), têm as seguintes
características em comum:

* `HP` (_hit points_) - Vida do personagem, entre 0 e 100; quando chega a zero
  o personagem morre.
* `SelectedWeapon` - A arma que o personagem usa em combate.
* `Inventory` - Lista de itens que o personagem transporta, nomeadamente comida
  e armas.
* `Gold` - Quantidade de ouro que o personagem possui.

Por sua vez, o jogador tem algumas características específicas:

* `Weight` - Peso total de tudo o que o jogador transporta, nomeadamente
  itens no inventário (armas e comida), arma selecionada e ouro.
* `MaxWeight` - Constante que define o peso máximo que o jogador consegue
  carregar.

Finalmente, os NPCs têm a seguinte característica específica:

* `State` - Estado do NPC, um de dois estados possíveis:
  * _Hostile_ - Ataca o jogador assim que o jogador se move para o respetivo
    _tile_.
  * _Neutral_ - NPC ignora o jogador quando o jogador se move para o respetivo
    _tile_. Caso o jogador ataque um NPC neste estado, o estado do NPC é
    alterado para _Hostile_.

#### Itens

Todos os itens têm as seguintes características:

* `Weight` - Peso do item.
* `Value` - Valor do item.

Existem os seguintes itens em concreto:

* Comida - Podem existir diferentes tipos de comida, à escolha dos alunos. Cada
  tipo diferente de comida fornece ao jogador um HP pré-definido (`HPIncrease`)
  quando usado.
* Armas - Podem existir diferentes tipos de armas, à escolha dos alunos. Cada
  tipo diferente de arma tem um `AttackPower` e `Durability` específicos. O
  primeiro, inteiro entre 1 e 100, representa o máximo de HP que o jogador pode
  retirar ao NPC quando o ataca. A `Durability`, _float_ entre 0 e 1, representa
  a probabilidade da arma não se estragar quando usada num ataque. As arma são
  retiradas do jogo no momento em que se estragam.
* Ouro - Pode ser usado como moeda em negociações com NPCs. Cada item de ouro
  tem um `Value` de 1 e um `Weight` de 0.1.

A comida e as armas podem ser colocadas no inventário do jogador. O jogador
pode ter ainda (fora do inventário) uma arma equipada e uma quantidade de ouro.
Todos estes itens contribuem para o peso carregado pelo jogador.

#### Mapas

Existe um mapa por nível, colocado aleatoriamente num _tile_. Caso o jogador
apanhe o mapa, todas as partes inexploradas do nível são reveladas.

#### Compra/venda de itens

O jogador pode negociar com NPCs no estado _Neutral_. Só são permitidas trocas
entre ouro e itens.

_A completar_

#### Combate

Um NPC `Hostile` ataca o jogador quando este entra ou se mantém no _tile_ onde
o NPC está presente. A quantidade de HP que o jogador perde é igual a um valor
aleatório entre 0 e o `AttackPower` da arma equipada pelo NPC.

O jogador pode atacar qualquer NPC presente no mesmo _tile_ selecionando a
opção `F`. A quantidade de HP que o jogador retira ao NPC é igual a um valor
aleatório entre 0 e o `AttackPower` da arma equipada.

Quando é realizado um ataque pelo jogador ou pelo NPC, existe uma probabilidade
igual a 1 - `Durability` da arma equipada se partir (no caso de ataque sem arma
esta questão é ignorada). Neste caso a arma é removida do respetivo inventário
e do jogo.

Caso o jogador ou o NPC não tenham uma arma equipada, podem: a) gastar uma
_turn_ a equipar uma arma que tenham no inventário; ou, b) atacar sem arma, com
um `AttackPower` inferior a qualquer arma do jogo. O jogador pode ainda fugir
para um _tile_ vizinho (os NPCs não se movem entre _tiles_).

Tal como o jogador, o NPC pode optar por gastar uma _turn_ a consumir comida
caso a tenha e caso o seu HP esteja muito baixo.

Caso o jogador vença o NPC (ou seja, caso o HP do NPC diminua até zero), o
NPC desaparece do jogo, deixando para trás os itens que carregava (comida,
armas e/ou ouro), que o jogador pode ou não apanhar.

Se o NPC vencer o jogador (ou seja, caso o HP do jogador chegue a zero), o jogo
termina.

#### Fim do jogo

O jogo pode terminar de duas formas:

1. Quando o HP do jogador baixa até zero devido a cansaço (pois o jogador perde
   1 HP por _turn_) ou devido a combate.
2. Quando o jogador seleciona a opção `Q`.

Em qualquer dos casos, verifica-se se o nível atingido está entre os 10
melhores, e em caso afirmativo, solicita-se ao jogador o seu nome para figurar
na tabela de _high scores_.

### Visualização do jogo

A visualização do jogo deve ser feita em modo de texto (consola).

#### Ecrã principal

O ecrã principal do jogo deve mostrar o seguinte:

* Mapa do jogo, distiguindo claramente a parte explorada da parte inexplorada.
* Estatísticas do jogador: nível atual, _hit points_ (HP), arma selecionada e
percentagem de ocupação do inventário.
* Em cada _tile_ do mapa explorado devem ser diferenciáveis os vários elementos
presentes (itens, NPCs, etc), até um máximo razoável.
* Uma legenda, explicando o que é cada elemento no mapa.
* Uma ou mais mensagens descrevendo o resultado da ação realizada na _turn_
anterior.
* Descrição do que está no _tile_ atual, bem como nos _tiles_ na respetiva
vizinhança de [Von Neumann].
* Indicação das ações realizáveis.

Uma vez que o C# suporta nativamente a representação [Unicode], os respetivos
caracteres podem e devem ser usados para melhorar a visualização do jogo. Para
o efeito deve ser incluída a instrução `Console.OutputEncoding = Encoding.UTF8;`
no método `Main()` (é necessário usar o _namespace_ `System.Text`).

A [Figura 1](#fig1) mostra uma possível implementação da visualização do jogo.

<a name="fig1"></a>

```
+++++++++++++++++++++++++++ LP1 Rogue : Level 009 +++++++++++++++++++++++++++

~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~    Player stats
~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~    ------------
                                                   HP        - 34
☿.... ☢.... ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~    Weapon    - Sword
..... ..... ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~    Inventory - 91% full

..... ..... ..... ..... ..... ~~~~~ ~~~~~ ~~~~~
..... ..... ..... ..... ..... ~~~~~ ~~~~~ ~~~~~

..... ..... ..... ?.... ..... †☿... ☿☿¶☢. ~~~~~    Legend
..... ..... ..... ..... ..... ..... ..... ~~~~~    ------
                                                      ⨀ - Player
~~~~~ ¶.... ..... ..... ✚☿... ..... ..... .....   EXIT! - Exit
~~~~~ ..... ..... ..... ..... ..... ..... .....       . - Empty
                                                      ~ - Unexplored
~~~~~ ~~~~~ ☢¶✚.. ..... ..... ..... ⨀☿†.. EXIT!       ¶ - Neutral NPC
~~~~~ ~~~~~ ..... ..... ..... ..... ..... EXIT!       ☿ - Hostile NPC
                                                      ✚ - Food
~~~~~ ~~~~~ ~~~~~ ~~~~~ ✚☢... ..... ☢$⍠.. ~~~~~       † - Weapon
~~~~~ ~~~~~ ~~~~~ ~~~~~ ..... ..... ..... ~~~~~       ☢ - Trap
                                                      $ - Gold
~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~       ⍠ - Map
~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~

Messages
--------
* You moved WEST
* You were attacked by a demon and lost 5 HP

What do I see?
--------------
* NORTH : Empty
* EAST  : Exit
* WEST  : Empty
* SOUTH : Trap, Gold (12)
* HERE  : Neutral NPC, Weapon

Options
-------
(W) Move NORTH      (A) Move WEST       (S) Move SOUTH    (D) Move EAST
(F) Attack NPC      (T) Trade with NPC
(E) Pick up item    (I) Inventory       (Q) Quit game

>
```

**Figura 1** - Possível implementação da visualização do jogo (ecrã principal).

#### Ecrã de ataque (opção F)

_A fazer_

#### Ecrã de compra/venda (opção T)

_A fazer_

#### Ecrã de apanhar item (opção E)

_A fazer_

#### Ecrã de inventário (opção I)

_A fazer_

#### Ecrã de terminação do jogo (opção Q)

_A fazer_

## Implementação

<a name="orgclasses"></a>

### Organização do projeto e estrutura de classes

O projeto deve estar devidamente organizado, fazendo uso de classes e
enumerações. Cada classe/enumeração deve ser colocada num ficheiro com o mesmo
nome. Por exemplo, uma classe chamada `Player` deve ser colocada no ficheiro
`Player.cs`. A estrutura de classes deve ser bem pensada e organizada de uma
forma lógica, e [cada classe deve ter uma responsabilidade específica e bem
definida][SRP].

<a name="fases"></a>

### Fases da implementação

O jogo pode ser implementado incrementalmente em várias fases. Os projetos
precisam de implementar pelo menos a Fase 1 para serem avaliados.

#### Fase 1

Na fase 1 devem ser implementandos os seguintes pontos:

* Menu principal, com todas as opções a funcionar excepto _High Scores_.
* Jogo:
  * Grelha do jogo contém apenas jogador e _Exit_, colocados aleatoriamente na
    1ª e 8ª colunas da grelha, respetivamente.
  * Jogador inicia jogo com HP igual a 100.
  * Jogador controlável com as teclas WASD, quando chega à _Exit_ termina o
    nível atual, começando um novo nível.
  * Jogador perde 1 HP por cada _move_ no 1º nível, 2 HP por cada _move_ no 2º
    nível, etc.
  * Jogador morre quando HP chega a zero.

A implementação completa desta fase equivale a 50% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 2.5).

#### Fase 2

Na fase 2 devem ser implementandos os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* Implementação das partes exploradas e inexploradas do mapa. As partes
  inexploradas devem ser claramente distinguíveis das partes exploradas.

A implementação completa desta fase equivale a 60% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 3).

#### Fase 3

Na fase 3 devem ser implementandos os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* Implementação de armadilhas: quando o jogador se move para um _tile_ que
  contém uma armadilha, perde automaticamente o HP especificado para a
  armadilha em questão.

A implementação completa desta fase equivale a 65% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 3.25).

#### Fase 4

Na fase 4 devem ser implementandos os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* Implementação dos _high scores_ usando ficheiros:
  * Opção _High Scores_ do menu principal permite visualizar os 10 melhores
    _scores_.
  * Quando jogador morre, _score_ é guardado caso esteja entre os 10 melhores
    _high scores_.

A implementação completa desta fase equivale a 70% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 3.5).

#### Fase 5

Na fase 5 devem ser implementandos os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* Jogador tem inventário que permite guardar itens até um peso máximo
  pré-determinado; implementação da funcionalidade `(I) Inventory`.
* Implementação da funcionalidade `(E) Pick up item`.
* Itens:
  * Comida, armas e ouro: quando apanhados são guardados no inventário do
    jogador, caso o mesmo ainda suporte o peso.
  * Mapas: quando apanhados revelam o nível na sua totalidade; não são
    guardados no inventário, mas tal como os restantes itens, desaparecem do
    nível quando apanhados.

A implementação completa desta fase equivale a 75% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 3.75).

#### Fase 6

Na fase 6 devem ser implementandos os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* O jogador pode equipar uma das armas que tem no seu inventário. A arma
  equipada não conta para o peso total do inventário. A arma anteriormente
  equipada é movida para o inventário, caso não ultrapasse o limite de peso do
  mesmo.

A implementação completa desta fase equivale a 80% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 4).

#### Fase 7

Na fase 7 devem ser implementandos os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* NPCs e combate passivo

A implementação completa desta fase equivale a 85% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 4.25).

#### Fase 8

Na fase 8 devem ser implementandos os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* NPCs e combate ativo

A implementação completa desta fase equivale a 90% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 4.5).

#### Fase 9

Na fase 9 devem ser implementandos os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* NPCs e compra/venda de itens

A implementação completa desta fase equivale a 95% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 4.75).

#### Fase 10

Na fase 10 devem ser implementandos os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* _a fazer_

A implementação completa desta fase equivale a 100% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 5).

#### Fase extra

Na fase extra devem ser implementandos os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* Implementação de _save games_, com opção extra no menu principal de _load
  game_.

A implementação completa desta fase permite compensar eventuais problemas
noutras partes do código e/ou do projeto, facilitando a obtenção da nota
máxima de 5 valores.

<a name="objetivos"></a>

## Objetivos e critério de avaliação

Este projeto tem os seguintes objetivos:

* **O1** - Jogo deve funcionar como especificado (ver [fases](#fases) de
  implementação, obrigatório implementar pelo menos a Fase 1).
* **O2** - Projeto e código bem organizados, nomeadamente: a) estrutura de
  classes bem pensada (ver secção <a href="#orgclasses">Organização do projeto
  e estrutura de classes</a>); b) código devidamente comentado e indentado; c)
  inexistência de código "morto", que não faz nada, como por exemplo
  variáveis ou métodos nunca usados; d) soluções [simples][KISS] e eficientes;
  e, e) projeto compila e executa sem erros e/ou  _warnings_.
* **O3** - Projeto adequadamente comentado e documentado. Documentação deve ser
  feita com comentários de documentação XML, e a documentação (gerada com
  [Doxygen], [Sandcastle] ou ferramenta similar) deve estar incluída no ZIP do
  projeto (mas não integrada no repositório Git).
* **O4** - Repositório Git deve refletir boa utilização do mesmo, com _commits_
  de todos os elementos do grupo e mensagens de _commit_ que sigam as melhores
  práticas para o efeito (como indicado
  [aqui](https://chris.beams.io/posts/git-commit/),
  [aqui](https://gist.github.com/robertpainsi/b632364184e70900af4ab688decf6f53),
  [aqui](https://github.com/erlang/otp/wiki/writing-good-commit-messages) e
  [aqui](https://stackoverflow.com/questions/2290016/git-commit-messages-50-72-formatting)).
* **O5** - Relatório em formato [Markdown] (ficheiro `README.md`), organizado
  da seguinte forma:
  * Título do projeto.
  * Nome dos autores (primeiro e último) e respetivos números de aluno.
  * Indicação do repositório público Git utilizado. Esta indicação é opcional,
    pois podem preferir desenvolver o projeto num repositório privado.
  * Informação de quem fez o quê no projeto. Esta informação é **obrigatória**
    e deve refletir os _commits_ feitos no Git.
  * Descrição da solução:
    * Fase implementada (1 a 10, ou extra).
    * Arquitetura da solução, com breve explicação de como o programa foi
      organizado e indicação das estruturas de dados usadas (para o inventário
      e para a grelha de jogo, por exemplo), bem como os algoritmos
      implementados (para desenhar o mapa, por exemplo).
    * Um diagrama UML descrevendo a estrutura de classes.
    * Um fluxograma mostrando o _game loop_.
  * Conclusões e matéria aprendida.
  * Referências:
    * Incluindo trocas de ideias com colegas, código aberto reutilizado e
      bibliotecas de terceiros utilizadas. Devem ser o mais detalhados
      possível.
  * **Nota:** o relatório deve ser simples e breve, com informação mínima e
    suficiente para que seja possível ter uma boa ideia do que foi feito.
    Atenção aos erros ortográficos, pois serão tidos em conta na nota final.

O projeto tem um peso de 5 valores na nota final da disciplina e será avaliado
de forma qualitativa. Isto significa que todos os objetivos têm de ser
parcialmente ou totalmente cumpridos. Ou seja, se os alunos ignorarem
completamente um dos objetivos, a nota final será zero.

A nota individual de cada aluno será atribuida com base na nota preliminar do
projeto, na percentagem de trabalho realizada (indicada no relatório e
verificada através dos _commits_) e na discussão do projeto. Se o aluno tiver
realizado uma percentagem equitativa do projeto e se souber explicar o que fez
durante a discussão, então a nota individual deverá ser muito semelhante à nota
preliminar.

## Entrega

O projeto deve ser entregue via Moodle até às 23h de 17 de junho de 2018.
Deve ser submetido um ficheiro `zip` com os seguintes conteúdos:

* Solução completa do projeto, contendo adicionalmente e obrigatoriamente:
  * Pasta escondida `.git` com o repositório Git local do projeto.
  * Documentação gerada com [Doxygen], [Sandcastle] ou ferramenta similar.
  * Ficheiro `README.md` contendo o relatório do projeto em formato [Markdown].
  * Ficheiros de imagem contendo o fluxograma e o diagrama UML de classes.

Notas adicionais para entrega:

* A solução deve ser entregue na forma de uma solução para Visual Studio 2017.
* O projeto deve ser do tipo Console App (.NET Framework ou .NET Core).
* Todos os ficheiros do projeto devem ser gravados em codificação [UTF-8]. Este
  pormenor é especialmente importante em Windows pois regra geral a codificação
  [UTF-8] não é usada por omissão. Em todo o caso, e dependendo do editor usado,
  a codificação [UTF-8] pode ser selecionada na janela de "Save as" / "Guardar
  como", ou então nas preferências do editor utilizado.

## Honestidade académica

Nesta disciplina, espera-se que cada aluno siga os mais altos padrões de
honestidade académica. Isto significa que cada ideia que não seja do
aluno deve ser claramente indicada, com devida referência ao respectivo
autor. O não cumprimento desta regra constitui plágio.

O plágio inclui a utilização de ideias, código ou conjuntos de soluções
de outros alunos ou indivíduos, ou quaisquer outras fontes para além
dos textos de apoio à disciplina, sem dar o respectivo crédito a essas
fontes. Os alunos são encorajados a discutir os problemas com outros
alunos e devem mencionar essa discussão quando submetem os projetos.
Essa menção **não** influenciará a nota. Os alunos não deverão, no
entanto, copiar códigos, documentação e relatórios de outros alunos, ou dar os
seus próprios códigos, documentação e relatórios a outros em qualquer
circunstância. De facto, não devem sequer deixar códigos, documentação e
relatórios em computadores de uso partilhado.

Nesta disciplina, a desonestidade académica é considerada fraude, com
todas as consequências legais que daí advêm. Qualquer fraude terá como
consequência imediata a anulação dos projetos de todos os alunos envolvidos
(incluindo os que possibilitaram a ocorrência). Qualquer suspeita de
desonestidade académica será relatada aos órgãos superiores da escola
para possível instauração de um processo disciplinar. Este poderá
resultar em reprovação à disciplina, reprovação de ano ou mesmo suspensão
temporária ou definitiva da ULHT.

_Texto adaptado da disciplina de [Algoritmos e
Estruturas de Dados][aed] do [Instituto Superior Técnico][ist]_

## Referências

* <a name="ref1">\[1\]</a> Whitaker, R. B. (2016). The C# Player's Guide
  (3rd Edition). Starbound Software.

## Licenças

Este enunciado é disponibilizados através da licença [CC BY-NC-SA 4.0].

## Metadados

* Autor: [Nuno Fachada]
* Curso:  [Licenciatura em Videojogos][lamv]
* Instituição: [Universidade Lusófona de Humanidades e Tecnologias][ULHT]

[GPLv3]:https://www.gnu.org/licenses/gpl-3.0.en.html
[CC BY-NC-SA 4.0]:https://creativecommons.org/licenses/by-nc-sa/4.0/
[lamv]:https://www.ulusofona.pt/licenciatura/videojogos
[Nuno Fachada]:https://github.com/fakenmc
[ULHT]:https://www.ulusofona.pt/
[aed]:https://fenix.tecnico.ulisboa.pt/disciplinas/AED-2/2009-2010/2-semestre/honestidade-academica
[ist]:https://tecnico.ulisboa.pt/pt/
[Markdown]:https://guides.github.com/features/mastering-markdown/
[Doxygen]:https://www.stack.nl/~dimitri/doxygen/
[Sandcastle]:https://github.com/EWSoftware/SHFB
[SRP]:https://en.wikipedia.org/wiki/Single_responsibility_principle
[KISS]:https://en.wikipedia.org/wiki/KISS_principle
[GP]:https://en.wikipedia.org/wiki/Procedural_generation
[Von Neumann]:https://en.wikipedia.org/wiki/Von_Neumann_neighborhood
[UTF-8]:https://en.wikipedia.org/wiki/UTF-8
[Unicode]:https://en.wikipedia.org/wiki/Unicode
