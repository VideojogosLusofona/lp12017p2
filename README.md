<!--
2º Projeto de Linguagens de Programação I 2017/2018 (c) by Nuno Fachada

2º Projeto de Linguagens de Programação I 2017/2018 is licensed under a
Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.

You should have received a copy of the license along with this
work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
-->

[![Enunciado: CC BY-NC-SA 4.0](https://img.shields.io/badge/Enunciado-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)
[![Código: MIT](https://img.shields.io/badge/Código-MIT-blue.svg)](http://opensource.org/licenses/MIT)

# 2º Projeto de Linguagens de Programação I 2017/2018

## Descrição do problema

Os alunos devem implementar, em grupos de 2 a 3 elementos, um jogo _roguelike_
em C# com níveis [gerados procedimentalmente](#procedural) em grelhas 8x8. O
jogador começa no lado esquerdo da grelha (1ª coluna), e o seu objetivo é
encontrar a saída do nível, que se encontra do lado direito dessa mesma grelha
(8ª coluna). Pelo meio o jogador pode encontrar NPCs (agressivos ou neutros),
encontrar itens (comida, armas, mapas), possivelmente apanhando-os, e cair em
armadilhas.

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

O jogo começa por apresentar o menu principal, que deve conter as seguintes
opções:

1. New game
2. High scores
3. Credits
4. Quit

Caso o utilizador selecione as opções 2 ou 3, é mostrada a informação
solicitada, após a qual o utilizador pressiona ENTER (ou qualquer tecla) para
voltar ao menu principal. A opção 4 termina o programa. Se for selecionada a
opção 1, começa um novo jogo.

#### Ações disponíveis no jogo

As ações disponíveis em cada _turn_ são as seguintes:

* `WSAD` para movimento.
* `F` para atacar um NPC no _tile_ atual.
* `E` para apanhar um item no _tile_ atual (incluindo mapas).
* `U` para usar um item (arma ou comida).
  * No caso de uma arma, a mesma é equipada (selecionada para combate). Caso
    exista uma arma equipada anteriormente, a mesma passa para o inventário.
  * No caso de comida, a mesma é consumida, aumentando o HP na quantidade
    especificada para a comida em questão, até um máximo de 100.
* `V` para deixar cair um item (arma ou comida) no _tile_ atual.
* `I` para mostrar informação acerca dos itens (armas e comida) e armadilhas
  disponíveis no jogo. Esta opção **não** consome uma _turn_.
* `Q` para terminar o jogo.

As opções `F`, `E`, `U` e `V` devem ser seguidas de um número, indicando qual o
NPC a atacar ou o item a apanhar/usar/deixar cair. Deve ser permitido cancelar
a opção antes da indicação do número, sem que o jogador perca uma _turn_.

Em cada _turn_ é consumido automaticamente 1 HP do jogador, independentemente
da ação realizada.

#### O jogador

O jogador tem várias características, algumas definidas diretamente, outras
calculáveis a partir das restantes:

* `HP` (_hit points_) - Vida do jogador, entre 0 e 100; quando chega a zero
  o jogador morre.
* `SelectedWeapon` - A arma que o jogador usa em combate.
* `Inventory` - Lista de itens que o jogador transporta, nomeadamente comida e
  armas.
* `MaxWeight` - Constante que define o peso máximo que o jogador pode carregar.
* `Weight` - Peso total de tudo o que o jogador transporta, nomeadamente
  itens no inventário (armas e comida) e a arma equipada. Não pode
  ultrapassar `MaxWeight`.

#### NPCs

Os NPCs têm as seguintes características:

* `HP` (_hit points_) - Vida do NPC, semelhante à do jogador. Inicialmente os
  NPCs devem ter HPs relativamente pequenos, aumentando à medida que o jogo
  progride para níveis mais difíceis. O HP inicial dos NPCs é
  [aleatório](#procedural), mas nunca ultrapassando o valor 100.
* `AttackPower` - O máximo de HP que o NPC pode retirar ao jogador em cada
  ataque. Inicialmente os NPCs devem ter um `AttackPower` relativamente pequeno,
  aumentando à medida que o jogo progride para níveis mais difíceis. O
  `AttackPower` de cada NPC é [aleatório](#procedural), mas nunca ultrapassando
  o valor 100.
* `State` - Estado do NPC, um de dois estados possíveis:
  * _Hostile_ - Ataca o jogador assim que o jogador se move para o seu _tile_.
  * _Neutral_ - NPC ignora o jogador quando o jogador se move para o seu
    _tile_. Caso o jogador ataque um NPC neste estado, o estado do NPC é
    alterado para _Hostile_.

#### Itens

Todos os itens têm a seguinte característica:

* `Weight` - Peso do item.

Existem os seguintes itens em concreto:

* Comida - Podem existir diferentes tipos de comida, à escolha dos alunos. Cada
  tipo diferente de comida fornece ao jogador um HP pré-definido
  (`HPIncrease`), que não pode ultrapassar o valor 100, quando usado.
* Armas - Podem existir diferentes tipos de armas, à escolha dos alunos. Cada
  tipo diferente de arma tem um `AttackPower` e `Durability` específicos. O
  primeiro, entre 1 e 100, representa o máximo de HP que o jogador pode retirar
  ao NPC quando o ataca. A `Durability`, entre 0 e 1, representa a
  [probabilidade](#procedural) da arma não se estragar quando usada num
  ataque. As armas são retiradas do jogo no momento em que se estragam.

Os itens podem existir em qualquer _tile_ do nível (exceto `EXIT!`) bem como
no inventário do jogador. No caso das armas, podem ainda ser equipadas pelo
jogador. Os itens podem também ser deixados cair pelos NPCs no _tile_ onde se
encontram após perderem um combate com o jogador.

#### Mapas

Existe um mapa por nível, colocado [aleatoriamente](#procedural) num _tile_.
Caso o jogador apanhe o mapa, todas as partes inexploradas do nível são
reveladas.

#### Combate

Um NPC `Hostile` ataca o jogador quando este entra ou se mantém no _tile_ onde
o NPC está presente. A quantidade de HP que o jogador perde é igual a um valor
[aleatório](#procedural) entre 0 e o `AttackPower` do NPC.

O jogador pode atacar qualquer NPC presente no mesmo _tile_ selecionando a
opção `F` e especificando qual o NPC a atacar. A quantidade de HP que o jogador
retira ao NPC é igual a um valor [aleatório](#procedural) entre 0 e o
`AttackPower` da arma equipada. O jogador não pode atacar NPCs senão tiver uma
arma equipada.

Quando é realizado um ataque pelo jogador, existe uma
[probabilidade](#procedural) igual a `1 - Durability` da arma equipada se
partir. Neste caso a arma é removida das "mãos" do jogador e do jogo.

Caso o jogador não tenha uma arma equipada, pode gastar uma _turn_ a equipar
uma arma que tenha no inventário. O jogador pode ainda gastar uma _turn_ a
consumir comida (caso a tenha) se considerar que o seu HP está muito baixo. Em
ambos os casos o jogador será atacado se estiver no mesmo _tile_ que um NPC
hostil.

Caso o jogador vença o NPC (ou seja, caso o HP do NPC diminua até zero), o NPC
desaparece do jogo, deixando para trás zero ou mais itens
[aleatórios](#procedural), que o jogador pode ou não apanhar. O número e
qualidade dos itens deixados para trás pelo NPC **não** varia com a dificuldade
do nível.

Se o NPC vencer o jogador (ou seja, caso o HP do jogador chegue a zero), o jogo
termina.

#### Armadilhas

As armadilhas têm as seguintes características:

* `MaxDamage` - Valor máximo de HP que jogador pode perder se cair na armadilha.
  É um valor entre 0 e 100.
* `FallenInto` - Indica se o jogador já caiu na armadilha ou não.

Podem existir diferentes tipos de armadilha no jogo, cada uma com um valor
específico para `MaxDamage`. É possível inclusive existir mais do que uma
armadilha por _tile_.

Quando o jogador entra pela primeira vez num _tile_ com uma ou mais armadilhas,
cada armadilha provoca uma perda [aleatória](#procedural) de HP ao jogador
entre 0 e `MaxDamage`, e o respetivo estado `FallenInto` passa a `true`. Se o
jogador voltar a entrar ou se passar mais _turns_ nesse _tile_, as armadilhas
já não causam estragos.

#### Fim do jogo

O jogo pode terminar de duas formas:

1. Quando o HP do jogador chega a zero devido a cansaço (pois o jogador perde
   1 HP por _turn_), devido a combate ou devido a armadilhas.
2. Quando o jogador seleciona a opção `Q`.

Em qualquer dos casos, verifica-se se o nível atingido está entre os 10
melhores, e em caso afirmativo, solicita-se ao jogador o seu nome para o mesmo
figurar na tabela de _high scores_.

#### Níveis e dificuldade

À medida que o jogo avança, os níveis vão ficando mais difíceis. Mais
concretamente, à medida que o jogo avança:

* Relativamente aos NPCs:
  * Devem tendencialmente existir em maior número.
  * A proporção _Hostiles_/_Neutrals_ deve ir aumentando.
  * O `HP` e `AttackPower` devem ser cada vez maiores (mas nunca ultrapassando
    o máximo, 100).
* Devem existir tendencialmente mais armadilhas.
* Devem existir tendencialmente menos itens (comida e armas) disponíveis para o
  jogador apanhar.

Na secção [Geração procedimental e aleatoriedade](#procedural) são apresentadas
algumas sugestões de como gerar infinitamente níveis de dificuldade cada vez
maior.

<a name="procedural"></a>

### Geração procedimental e aleatoriedade

<!--

### Geração de níveis

NPCs:
quantidade
HP, attackpower

Jogador e exit
Armadilhas
Itens
Mapa

#### Durante o jogo

Combate: HP perdido entre 0 e attackpower
Armadilhas: HP perdido entre 0 e Damage
Probablidade de arma se partir
Itens deixados pelo NPC qd morre

-->
A [geração procedimental][GP] é uma peça fundamental na história dos Videojogos,
tanto antigos como atuais. A [geração procedimental][GP] consiste na criação
algorítmica e automática de dados, por oposição à criação manual dos mesmos. É
usada nos Videojogos para criar grandes quantidades de conteúdo, promovendo a
imprevisibilidade e a rejogabilidade dos jogos.

O C# oferece a classe [Random][] para geração de números aleatórios, que por
sua vez tem vários métodos úteis. Para usarmos esta classe é primeiro
necessário criar uma instância da mesma:

```cs
// Criar uma instância de Random usando como semente a hora atual do sistema
// Para efeitos de debugging durante o desenvolvimento do jogo pode ser
// conveniente usar uma semente fixa
Random rnd = new Random();
```

Um dos métodos úteis é o método [NextDouble()][], que retorna um `double` entre
0 e 1. É possível "atirar a moeda ao ar" usando este método, por exemplo:

```cs
if (rnd.NextDouble() < 0.25)
{
    Console.WriteLine("Cara");
}
else
{
    Console.WriteLine("Coroa");
}
```

No exemplo anterior definimos a probabilidade de sair "Cara" em 25% (e
consequentemente, de sair "Coroa" em 75%). O mesmo tipo de código pode ser
usado para determinar se a arma do jogador se estragou durante um ataque:

```cs
if (rnd.NextDouble() < 1 - weapon.Durability)
{
    // Arma estragou-se, fazer qualquer coisa sobre isso
}
```

O HP a ser subtraído devido a ataque ou armadilhas também pode ser determinado
com o método [NextDouble()][], multiplicando o valor retornado pelo possível
máximo em questão. Por exemplo:

```cs
// Valor de HP a subtrair num ataque, será no máximo igual a AttackPower
double damage = Random.NextDouble() * weapon.AttackPower;
```

```cs
// Valor de HP a subtrair devido a armadilha, será no máximo igual a MaxDamage
double damage = Random.NextDouble() * trap.MaxDamage;
```

O método [NextDouble()][] pode ainda ser usado para determinar o `HP` inicial,
o `AttackPower` e o `State` dos NPCs. No caso das duas primeiras
características, basta multiplicar o valor de retorno de [NextDouble()][] pelo
máximo desejado (nunca superior a 100). No caso do `State`, que pode ter apenas
dois valores discretos, usamos um cálculo de probabilidade como fizemos no
exemplo "cara ou coroa".

A classe [Random][] disponibiliza também três versões (_overloads_) do método
[Next()][], úteis para obter números inteiros aleatórios:

* `Next()` - Retorna um inteiro aleatório não-negativo.
* `Next(int b)` - Retorna um inteiro aleatório no intervalo `[0, b[`.
* `Next(int a, int b)` - Retorna um inteiro aleatório no intervalo `[a, b[`.

Estes métodos são apropriados para determinar a quantidade inicial de NPCs,
itens e armadilhas, o número de itens deixados para trás por um NPC quando
morre, bem como a posição inicial do jogador, da saída e do mapa.

O seguinte código exemplifica uma possível forma de criar os NPCs para um novo
nível (atenção que o código é meramente exemplificativo):

```cs
// Quantidade inicial de NPCs no nível
int numberOfNPCs = rnd.Next(maxNPCsForThisLevel);

// Criar cada um dos NPCs
for (int i = 0; i < numberOfNPCs; i++)
{
    // Determinar HP inicial do NPC
    double hp = rnd.NextDouble() * maxHPForThisLevel;
    // Determinar AttackPower do NPC
    double attackPower = rnd.NextDouble() * maxAPForThisLevel;
    // Determinar State do NPC
    NPCState state = rnd.NextDouble() < hostileProbabilityForThisLevel
        ? NPCState.Hostile
        : NPCState.Neutral;

    // Determinar posição do NPC
    int row = rnd.Next(8); // Boa ideia se 8 for uma constante tipo levelRows
    int col = rnd.Next(8); // Boa ideia se 8 for uma constante tipo levelCols

    // Criar NPC
    NPC npc = new NPC(hp, attackPower, state);

    // Adicionar NPC ao tile escolhido aleatoriamente
    level[row, col].Add(npc);
}
```

O código anterior assume que as variáveis `maxNPCsForThisLevel`,
`maxHPForThisLevel`, `maxAPForThisLevel` e `hostileProbabilityForThisLevel` já
existem. Estas variáveis devem ir aumentando de valor à medida que o jogador
vai passando os níveis. A forma mais simples consiste em usar uma
[função][funções] para relacionar a variável desejada (*y*) com o nível atual
do jogo (*x*). Algumas funções apropriadas para o efeito são a
[função linear][], a [função linear por troços][], a [função logística][] ou a
[função logarítmica][]. No site disponibilizado através deste [link][funções],
é possível manipular os diferentes parâmetros das várias funções de modo a
visualizar como as mesmas podem relacionar o nível atual (*x*) com o valor de
saída desejado (*y*). É também [disponibilizada uma classe _static_](ProcGenFunctions.cs)
com as várias funções sugeridas.

<a name="visualize"></a>

### Visualização do jogo

A visualização do jogo deve ser feita em modo de texto (consola).

#### Ecrã principal

O ecrã principal do jogo deve mostrar o seguinte:

* Mapa do jogo, distinguindo claramente a parte explorada da parte inexplorada.
* Estatísticas do jogador: nível atual, _hit points_ (HP), arma selecionada e
  percentagem de ocupação do inventário.
* Em cada _tile_ do mapa explorado devem ser diferenciáveis os vários elementos
  presentes (itens, NPCs, etc), até um máximo razoável.
* Uma legenda, explicando o que é cada elemento no mapa.
* Uma ou mais mensagens descrevendo o resultado das ações realizadas na _turn_
  anterior por parte dos jogadores e dos _NPCs_ no _tile_ atual.
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
                                                   HP        - 34.4
☿.... ☢.... ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~    Weapon    - Rusty Sword
..... ..... ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~    Inventory - 91.7% full

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
~~~~~ ~~~~~ ~~~~~ ~~~~~ ✚☢... ..... ☢⍠... ~~~~~       † - Weapon
~~~~~ ~~~~~ ~~~~~ ~~~~~ ..... ..... ..... ~~~~~       ☢ - Trap
                                                      ⍠ - Map
~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~
~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~ ~~~~~

Messages
--------
* You moved WEST
* You were attacked by an NPC and lost 5.3 HP

What do I see?
--------------
* NORTH : Empty
* EAST  : Exit
* WEST  : Empty
* SOUTH : Trap (Hell Pit), Map
* HERE  : NPC (Hostile, HP=14.2, AP= 8.5), Weapon (Shiny Sword)

Options
-------
(W) Move NORTH  (A) Move WEST    (S) Move SOUTH (D) Move EAST
(F) Attack NPC  (E) Pick up item (U) Use item   (V) Drop item
(I) Information (Q) Quit game

>
```

**Figura 1** - Possível implementação da visualização do jogo (ecrã principal).

#### Ecrã de ataque (opção F)

A opção `F` pode ser utilizada quando existem NPCs no mesmo _tile_ do jogador.
Deve ser mostrada uma mensagem de erro quando a opção `F` é selecionada e não
existem NPCs no _tile_ onde o jogador se encontra. Caso existam NPCs no _tile_,
deve ser apresentado um menu semelhante ao indicado na [Figura 2](#fig2).

<a name="fig2"></a>

```
Select NPC to attack
--------------------

0. Go back
1. Hostile, HP=19.7, AP= 3.0
2. Neutral, HP=62.1, AP=22.8
3. Hostile, HP=31.9, AP= 9.3

>
```

**Figura 2** - Possível menu para seleção de NPC a atacar.

#### Ecrã de apanhar/usar/deixar cair item (opções E, U e V)

A opção `E` pode ser utilizada quando existem itens no mesmo _tile_ do jogador.
Deve ser mostrada uma mensagem de erro quando a opção `E` é selecionada e não
existem itens no _tile_ onde o jogador se encontra.

As opções `U` e `V` podem ser utilizadas quando existem itens no inventário do
jogador. Deve ser mostrada uma mensagem de erro quando uma destas opções é
selecionada e não existem itens no inventário do jogador.

Caso existam itens no inventário deve ser apresentado um menu semelhante ao
indicado na [Figura 3](#fig3).

<a name="fig3"></a>

```
Select item to XXXX
-------------------

0. Go back
1. Weapon (Cursed Dagger)
2. Food (Apple)

>
```

**Figura 3** - Possível menu para seleção de item. `XXXX` deve ser substituído
por `pick up`, `use` ou `drop`, dependendo da opção escolhida.

#### Ecrã de informação (opção I)

Este ecrã aparece quando é selecionada a opção `I`, mostrando informação sobre
os diferentes itens e armadilhas existentes no jogo. O jogador deve pressionar
ENTER ou qualquer tecla para voltar ao ecrã principal, que deve ser redesenhado.
O uso desta opção **não** gasta uma _turn_. A [Figura 4](#fig4) mostra um
possível ecrã de informação (os itens e armadilhas apresentadas são meramente
exemplificativos).

<a name="fig4"></a>

```
Food             HPIncrease      Weight
---------------------------------------
Apple                    +4         0.5
Eggs                     +5         0.6
Fish                    +10         1.0
Meat                    +10         1.2
Water                    +2         0.8

Weapon          AttackPower      Weight     Durability
------------------------------------------------------
Shiny Sword            10.0         3.0           0.90
Rusty Sword            10.0         3.0           0.60
Shiny Dagger            5.0         1.0           0.95
Cursed Dagger          12.0         1.0           0.20
Power Axe              18.0         8.0           0.92
Heavy Mace             16.0         7.0           0.96
Chainsaw               40.0        20.0           0.50

Trap              MaxDamage
---------------------------
Hell Pit                -10
Sharp Spikes            -15
Banana Peel              -3
Bear Trap                -8
Bottomless Chasm        -30
```

**Figura 4** - Possível ecrã de informação (os itens e armadilhas apresentadas
são meramente exemplificativos).

#### Ecrã de terminação do jogo (opção Q)

Quando a opção `Q` é selecionada deve ser apresentada uma pergunta de
confirmação do género `Do you really want to quit? (y/n)`.

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

O jogo deve ser implementado incrementalmente em várias fases. Os projetos
precisam de implementar pelo menos a Fase 1 para serem avaliados. Atenção que a
[geração procedimental/aleatória](#procedural) dos elementos do jogo, bem como
a [visualização](#visualize), são **obrigatórias** em todas as fases de
implementação.

Para fins de avaliação, a fase tida em conta é a anterior à fase mais baixa que
ficou por implementar. Por exemplo, se o grupo implementar tudo até à fase 5
(inclusive), bem como as fases 7 e 9, a fase tida em conta para avaliação é a
fase 5. Ou seja, é vantajoso seguir a ordem sugerida para as fases de
implementação e não "saltar" fases.

#### Fase 1

Na fase 1 devem ser implementados os seguintes pontos:

* Menu principal, com todas as opções a funcionar excepto _High Scores_.
* Jogo:
  * Grelha do jogo contém jogador e _Exit_, colocados
    [aleatoriamente](#procedural) na 1ª e 8ª colunas da grelha, respetivamente.
  * Jogador inicia jogo com HP igual a 100.
  * Jogador controlável com as teclas WASD, quando chega à _Exit_ termina o
    nível atual, começando um novo nível.
  * Jogador perde 1 HP por cada _turn_.
  * Jogador morre quando HP chega a zero.

A implementação completa desta fase equivale a 50% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 2.5).

#### Fase 2

Na fase 2 devem ser implementados os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* Implementação das partes exploradas e inexploradas do mapa. As partes
  inexploradas devem ser claramente distinguíveis das partes exploradas.

A implementação completa desta fase equivale a 60% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 3).

#### Fase 3

Na fase 3 devem ser implementados os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* Implementação dos mapas e da funcionalidade `(E) Pick up item` apenas para
  mapas. Quando apanhados, os mapas revelam o nível na sua totalidade. Os mapas
  não são guardados no inventário, desaparecendo do nível quando apanhados.

A implementação completa desta fase equivale a 65% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 3.25).

#### Fase 4

Na fase 4 devem ser implementados os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* Implementação de armadilhas: quando o jogador se move pela primeira vez para
  um _tile_ que contém uma armadilha, perde HP entre 0 e o valor de `MaxDamage`
  da armadilha em questão.
* Implementação da opção `(I) Information`, que apresenta informação acerca dos
  diferentes tipos de armadilha no jogo.

A implementação completa desta fase equivale a 70% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 3.5).

#### Fase 5

Na fase 5 devem ser implementados os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* Implementação dos _high scores_ usando ficheiros:
  * Opção _High Scores_ do menu principal permite visualizar os 10 melhores
    _scores_.
  * Quando jogador morre ou seleciona a opção `Q`, _score_ é guardado caso
    esteja entre os 10 melhores.

A implementação completa desta fase equivale a 75% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 3.75).

#### Fase 6

Na fase 6 devem ser implementados os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* Jogador tem inventário que permite guardar itens até um peso máximo
  pré-determinado.
* Implementação das funcionalidades `(E) Pick up item` e `(V) Drop item` para
  comida e armas. Quando este tipo de itens (comida e armas) são apanhados, são
  guardados no inventário do jogador, caso o mesmo ainda suporte o peso.
* Atualização da opção `(I) Information` de modo a mostrar informação acerca
  dos diferentes itens existentes no jogo.

A implementação completa desta fase equivale a 80% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 4).

#### Fase 7

Na fase 7 devem ser implementados os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* Implementação da funcionalidade `(U) Use item`, nomeadamente:
  * O jogador pode consumir itens de comida presentes no seu inventário, e o
    seu `HP` deve aumentar de acordo com a comida consumida, até ao máximo de
    100.
  * O jogador pode equipar uma das armas que tem no seu inventário. A arma
    equipada continua a contar para o peso total do inventário. A arma
    anteriormente equipada é movida para o inventário.

A implementação completa desta fase equivale a 85% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 4.25).

#### Fase 8

Na fase 8 devem ser implementados os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* Implementação de NPCs com as características pedidas. Os NPCs existem no jogo
  e aparecem na visualização, mas não interferem, não atacam o jogador e não
  podem ser atacados.

A implementação completa desta fase equivale a 90% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 4.5).

#### Fase 9

Na fase 9 devem ser implementados os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* Combate passivo: o jogador é atacado por NPCs hostis quando se move para
  _tile_ onde os mesmos se encontrem.

A implementação completa desta fase equivale a 95% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 4.75).

#### Fase 10

Na fase 10 devem ser implementados os seguintes pontos (além dos pontos
indicados nas fases anteriores):

* Combate ativo: implementação da opção `(F) Attack NPC`.

A implementação completa desta fase equivale a 100% de cumprimento do
[objetivo **O1**](#objetivos) (nota máxima 5).

#### Fase extra

Na fase extra devem ser implementados os seguintes pontos (além dos pontos
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
  classes bem pensada (ver secção [Organização do projeto e estrutura de
  classes](#orgclasses)); b) código devidamente comentado e indentado; c)
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
      implementados (para desenhar o mapa e para geração procedimental, por
      exemplo).
    * Um diagrama UML mostrando as relações entre as classes e tipos
      desenvolvidos no jogo. Não é necessário indicar os conteúdos das classes
      (variáveis, propriedades, métodos, etc).
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

A nota individual de cada aluno será atribuída com base na avaliação do
projeto, na percentagem de trabalho realizada (indicada no relatório e
verificada através dos _commits_) e na discussão do projeto. Se o aluno tiver
realizado uma percentagem equitativa do projeto e se souber explicar o que fez
durante a discussão, então a nota individual deverá ser muito semelhante à
avaliação do projeto.

## Entrega

O projeto deve ser entregue via Moodle até às 23h de 20 de junho de 2018.
Deve ser submetido um ficheiro `zip` com os seguintes conteúdos:

* Solução completa do projeto, contendo adicionalmente e obrigatoriamente:
  * Pasta escondida `.git` com o repositório Git local do projeto.
  * Documentação gerada com [Doxygen], [Sandcastle] ou ferramenta similar.
  * Ficheiro `README.md` contendo o relatório do projeto em formato [Markdown].
  * Ficheiros de imagem contendo o fluxograma e o diagrama UML de classes.

Notas adicionais para entrega:

* Os grupos podem ter entre 2 a 3 elementos.
* A solução deve ser entregue na forma de uma solução para Visual Studio 2017.
* O projeto deve ser do tipo Console App (.NET Framework ou .NET Core).
* Todos os ficheiros do projeto devem ser gravados em codificação [UTF-8]. Este
  pormenor é especialmente importante em Windows pois regra geral a codificação
  [UTF-8] não é usada por omissão. Em todo o caso, e dependendo do editor usado,
  a codificação [UTF-8] pode ser selecionada na janela de "Save as" / "Guardar
  como", ou então nas preferências do editor utilizado.

## Honestidade académica

Nesta disciplina, espera-se que cada aluno siga os mais altos padrões de
honestidade académica. Isto significa que cada ideia que não seja do aluno deve
ser claramente indicada, com devida referência ao respetivo autor. O não
cumprimento desta regra constitui plágio.

O plágio inclui a utilização de ideias, código ou conjuntos de soluções de
outros alunos ou indivíduos, ou quaisquer outras fontes para além dos textos de
apoio à disciplina, sem dar o respetivo crédito a essas fontes. Os alunos são
encorajados a discutir os problemas com outros alunos e devem mencionar essa
discussão quando submetem os projetos. Essa menção **não** influenciará a nota.
Os alunos não deverão, no entanto, copiar códigos, documentação e relatórios de
outros alunos, ou dar os seus próprios códigos, documentação e relatórios a
outros em qualquer circunstância. De facto, não devem sequer deixar códigos,
documentação e relatórios em computadores de uso partilhado.

Nesta disciplina, a desonestidade académica é considerada fraude, com todas as
consequências legais que daí advêm. Qualquer fraude terá como consequência
imediata a anulação dos projetos de todos os alunos envolvidos (incluindo os
que possibilitaram a ocorrência). Qualquer suspeita de desonestidade académica
será relatada aos órgãos superiores da escola para possível instauração de um
processo disciplinar. Este poderá resultar em reprovação à disciplina,
reprovação de ano ou mesmo suspensão temporária ou definitiva da ULHT.

_Texto adaptado da disciplina de [Algoritmos e
Estruturas de Dados][aed] do [Instituto Superior Técnico][ist]_

## Referências

* <a name="ref1">\[1\]</a> Whitaker, R. B. (2016). The C# Player's Guide
  (3rd Edition). Starbound Software.
* <a name="ref2">\[2\]</a> Procedural generation. (2018). Retrived May 25, 2018
from https://en.wikipedia.org/wiki/Procedural_generation.

## Licenças

Este enunciado é disponibilizados através da licença [CC BY-NC-SA 4.0]. O código associado é disponibilizado através da licença
[MIT](http://opensource.org/licenses/MIT).

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
[Random]:https://docs.microsoft.com/pt-pt/dotnet/api/system.random
[NextDouble()]:https://docs.microsoft.com/pt-pt/dotnet/api/system.random.nextdouble
[Next()]:https://docs.microsoft.com/pt-pt/dotnet/api/system.random.next
[função logística]:https://en.wikipedia.org/wiki/Logistic_function
[função linear por troços]:https://en.wikipedia.org/wiki/Piecewise_linear_function
[função logarítmica]:https://en.wikipedia.org/wiki/Logarithm#Logarithmic_function
[função linear]:https://en.wikipedia.org/wiki/Linear_function_(calculus)
[funções]:https://www.desmos.com/calculator/x5nmemnwsu
