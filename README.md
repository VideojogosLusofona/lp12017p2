<!--
2º Projeto de Linguagens de Programação I 2017/2018 (c) by Nuno Fachada

2º Projeto de Linguagens de Programação I 2017/2018 is licensed under a
Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.

You should have received a copy of the license along with this
work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
-->

# 2º Projeto de Linguagens de Programação I 2017/2018

## Descrição do problema

Os alunos devem implementar, em grupo de 2 a 3 elementos, um jogo _roguelike_
usando a linguagem C#.

### O jogo

Os alunos devem implementar um jogo _roguelike_ em C# com níveis
[gerados procedimentalmente][GP] em grelhas 8x8. O jogador começa no lado
esquerdo da grelha (1ª coluna), e o seu objetivo é encontrar a saída do nível,
que se encontra do lado direito dessa mesma grelha (8ª coluna). Pelo meio o
jogador pode encontrar NPCs (monstros, comerciantes) e encontrar itens
(_power-ups_, _gold_, armas, escudos/armaduras, mapas), possivelmente
apanhando-os. Podem eventualmente existir armadilhas ou segredos, sendo que
estes últimos podem revelar-se armadilhas ou itens úteis.

Os níveis vão ficando progressivamente mais difíceis, com mais monstros, menos
itens e mais armadilhas. O _score_ final do jogador é igual ao nível atingido,
existindo uma tabela dos top 20 _high scores_, que deve persistir quando o
programa termina e o PC é desligado.

No início de cada nível, o jogador só tem conhecimento da sua vizinhança (de
[Moore]). À medida que o jogador se desloca, o mapa vai-se revelando. O jogador
só pode deslocar-se na sua vizinhança de [Von Neumann] usando as teclas WASD
(não usar _keypad_, pois o mesmo não existe em alguns portáteis, dificultando a
avaliação do jogo).

<a name="visualize"></a>

### Visualização do jogo

A visualização do jogo deve ser feita em modo de texto (consola). Deve ser
mostrado o seguinte:

* Mapa do jogo, distiguindo claramente a parte explorada da parte inexplorada.
* Em cada _tile_ do mapa explorado devem ser diferenciáveis os vários elementos
presentes (itens, NPCs, etc), até um máximo razoável. Isto significa que um
caractér pode não ser suficiente para representar razoavelmente um _tile_.
* Uma legenda, explicando o que é cada elemento no mapa.
* Uma ou mais mensagens descrevendo o resultado da ação realizada na _turn_
anterior.
* Mensagens descrevendo a _turn_ atual, nomeadamente o que está no tile atual e
que ações é possível realizar, bem como o que está em cada um dos quadrados da
vizinhança de [Von Neumann].

Uma vez que o C# suporta nativamente a representação [Unicode], os respetivos
caracteres podem e devem ser usados para melhorar a visualização do jogo. Para
o efeito deve ser incluída a instrução `Console.OutputEncoding = Encoding.UTF8;`
no método `Main()` (é necessário usar o _namespace_ `System.Text`).

```
..... ..... ..... ..... ..... ..... ..... .....    Player stats
..... ..... ..... ..... ..... ..... ..... .....    ------------
                                                   Level     - 14
..... ..... ..... ..... ..... ..... ..... .....    HP        - 34
..... ..... ..... ..... ..... ..... ..... .....    Weapon    - Sword
                                                   Inventory - 91% full
..... ..... ..... ..... ..... ..... ..... .....
..... ..... ..... ..... ..... ..... ..... .....

..... ..... ..... ..... ..... ..... ..... .....    Legend
..... ..... ..... ..... ..... ..... ..... .....    ------
                                                      ⨀ - Player
..... ..... ..... ..... ..... ..... ..... .....    EXIT - Exit
..... ..... ..... ..... ..... ..... ..... .....       . - Empty
                                                      ~ - Unexplored
..... ..... ..... ..... ..... ..... ⨀.... EXIT.       ꘐ - Neutral NPC
..... ..... ..... ..... ..... ..... ..... EXIT.       ꘒ - Hostile NPC
                                                      ⛨ - HP Boost
..... ..... ..... ..... ..... ..... ..... .....       † - Weapon
..... ..... ..... ..... ..... ..... ..... .....       ☢ - Trap
                                                      ? - Secret
..... ..... ..... ..... ..... ..... ..... .....       $ - Gold
..... ..... ..... ..... ..... ..... ..... .....

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

What will I do?
---------------
* W - Move NORTH
* A - Move WEST
* S - Move SOUTH
* D - Move EAST
* F - Attack NPC
* T - Trade with NPC
* I - Go to Inventory
```

### Modo de funcionamento

Ações disponíveis (cada ação requer uma _turn_):

* WSAD para movimento (apenas aparecem movimentos válidos)
* F, seguido de um número, para atacar um NPC no _tile_ atual
* E, seguido de um número, para apanhar um item no _tile_ atual
* G, seguido de um número, para largar um item no _tile_ atual
* T, seguido de um número, para negociar com um comerciante no _tile_ atual

 Cada _turn_ consome um HP do jogador.

### NPCs

Todos os NPCs têm o seu HP e poder de ataque próprios. Os NPCs podem estar em
três estados:

* _Hostile_ - Ataca o jogador assim que o jogador se move para o respetivo
_tile_.
* _Neutral_ - NPC ignora o jogador.

O jogador pode atacar qualquer NPC, e a partir desse momento o estado do NPC
passa a ser _Hostile_. O jogador

### Combate

Os comerciantes

<a name="orgclasses"></a>

### Organização do projeto e estrutura de classes

O projeto deve estar devidamente organizado, fazendo uso de classes e
enumerações. Cada classe/enumeração deve ser colocada num ficheiro com o mesmo
nome. Por exemplo, uma classe chamada `Player` deve ser colocada no ficheiro
`Player.cs`. A estrutura de classes deve ser bem pensada e organizada de uma
forma lógica, e [cada classe deve ter uma responsabilidade específica e bem
definida][SRP].

<a name="objetivos"></a>

## Objetivos e critério de avaliação

Este projeto tem os seguintes objetivos:

* **O1** - Jogo deve funcionar como especificado.
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
    * Arquitetura da solução, com breve explicação de como o programa foi
      organizado e indicação das estruturas de dados (para _a fazer_) e
      algoritmos (para _a fazer_, por exemplo) utilizados.
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

O projeto deve ser entregue via Moodle até às 23h de 10 de junho de 2018.
Deve ser submetido um ficheiro `zip` com os seguintes conteúdos:

* Solução completa do projeto, contendo adicionalmente e obrigatoriamente:
  * Pasta escondida `.git` com o repositório Git local do projeto.
  * Documentação gerada com [Doxygen], [Sandcastle] ou ferramenta similar.
  * Ficheiro `README.md` contendo o relatório do projeto em formato [Markdown].
  * Ficheiros de imagem contendo o fluxograma e o diagrama UML de classes.

Notas adicionais para entrega:

* A solução deve ser desenvolvida no Visual Studio 2017, Visual Studio Code,
  Visual Studio Mac ou MonoDevelop.
* O projeto deve ser do tipo Console App (preferencialmente .NET Framework).
* Todos os ficheiros do projeto devem ser gravados em codificação [UTF-8]. Este
  pormenor é especialmente importante em Windows pois regra geral a codificação
  [UTF-8] não é usada por omissão. Em todo o caso, e dependendo do editor usado,
  a codificação [UTF-8] pode ser selecionada na janela de "Save as" / "Guardar
  como", ou então nas preferências do editor utilizado.

## Extensões opcionais

_A definir_

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
[Moore]:https://en.wikipedia.org/wiki/Moore_neighborhood
[Von Neumann]:https://en.wikipedia.org/wiki/Von_Neumann_neighborhood
[UTF-8]:https://en.wikipedia.org/wiki/UTF-8
[Unicode]:https://en.wikipedia.org/wiki/Unicode
