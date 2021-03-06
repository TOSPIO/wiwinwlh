 <p class="center logo">
![](img/title.png)
</p>

原作者：

* Stephen Diehl (<a class="author" href="https://twitter.com/smdiehl">@smdiehl</a> )

译者：

* Savor d'Isavano ([GMail](mail:anohigisavay@gmail.com))
* Cindy Xu ([Github](https://github.com/CincyXu))

Savor d'Isavano（译者）声明：本翻译在力争充分传达原作者意图的原则上，对于专业术语，
尤其是国内没有形成统一翻译的术语，仍尽量根据自己的理解进行翻译；
对于某些专有名词或代码（如Cabal、Hackage、Nix、GHC Core、Maybe、StateT等）以及实难找到合适的中文词藻的词语，则保留原文。


本书中所有源代码均在[此处](https://github.com/TOSPIO/wiwinwlh/tree/master/src)。
若发现本文中存在任何谬误或你找到任何比文中更为清晰明了的示例，请不吝在Github提交pull request。

本文是该系列的第三版。

**原文许可声明**

本文中的代码和文本均奉献给“公有领域”。本文可以自由复制、修改、分发，甚至用于商业用途而无须征求作者同意。

**译文许可声明**

本译文声明为CC BY-NC-ND 2.0许可。
参见：

* [Creative Commons -- Attribution-NonCommercial-NoDerivs 4.0 International -- CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/)
* [Creative Commons -- 署名 - 非商业性使用 - 禁止演绎 4.0 国际 -- CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/deed.zh)

**修订历史**

**2.2**

新增和大规模修改的章节：

* 无条件匹配模式
* Hackage
* 模式完整度
* 调用栈
* 惰性
* Skolem Capture
* Foreign Function Pointers
* Attoparsec Parser
* Inline Cmm
* PrimMonad
* Specialization
* unbound-generics
* Editor Integration
* EKG
* Nix
* Haddock
* Monad Tutorials Commentary
* Monad Morphisms
* Corecursion
* Category
* 箭头
* Bifunctors
* ExceptT
* hint / mueval
* Roles
* Higher Kinds
* Kind Polymorphism
* Numeric Tower
* SAT Solvers
* Graph
* Sparks
* Threadscope
* Generic Parsers
* GHC Block Diagram
* GHC Debug Flags
* Core
* Inliner
* Unboxed Types
* Runtime Memory Representation
* ghc-heapview
* STG
* Worker/Wrapper
* Z-Encoding
* Cmm
* Runtime Optimizations
* RTS Profiling
* Algebraic Relations

基础
======

Cabal
-----

Cabal是Haskell的构建系统，兼有包管理器的功能。

例如：从Hackage中安装[parsec](http://hackage.haskell.org/package/parsec)包到本地，执行install命令：

```bash
$ cabal install parsec           # 最新版
$ cabal install parsec==3.1.5    # 特定版本
```

构建Haskell包的一般步骤如下：

```bash
$ cabal get parsec    # 获取源代码
$ cd parsec-3.1.5

$ cabal configure
$ cabal build
$ cabal install
```

从Hackage更新本地包索引，执行：

```bash
$ cabal update
```

创建一个新的Haskell项目，执行：

```bash
$ cabal init
$ cabal configure
```

此时会创建一个包含新项目配置选项的``.cabal``文件。

Cabal > 1.18中加入一个“沙盒”（sandbox）功能。沙盒是一个独立的Haskell包环境，与全局环境隔离。
沙盒保存在项目根目录下的``./.cabal-sandbox``中。要创建沙盒，执行以下命令：

```bash
$ cabal sandbox init
```

要删除沙盒，执行以下命令：

```bash
$ cabal sandbox delete
```

在安装沙盒的项目的工作目录中执行cabal命令与正常执行的效果有所不同，比如``cabal install``只会
改变本地包索引，不会影响全局配置。

要在沙盒中安装cabal文件中指定的依赖项，执行以下命令：

```bash
$ cabal install --only-dependencies
```

可以使用``-j<n>`` 开关打开并行构建。`n`是并行数。

```bash
$ cabal install -j4 --only-dependencies
```

来看一个cabal文件的例子。有两种主要的入口点：``library``（库）和``executable``（可执行项）。
一个cabal文件可以定义多个可执行项，而只能定义一个库。此外还有一个特殊的入口点
``Test-Suite``，定义了让cabal执行单元测试的接口。

对于库，使用``exposed-modules``来指定包结构中的哪些模块在包安装之后是公共可见的，
也就是我们希望下游用户调用的API。

对于可执行项，使用``main-is``来指定项目的主要模块，这个模块必须导出一个``main``函数作为程序的执行入口。

```bash
name:               mylibrary
version:            0.1
cabal-version:      >= 1.10
author:             Paul Atreides
license:            MIT
license-file:       LICENSE
synopsis:           The code must flow.
category:           Math
tested-with:        GHC
build-type:         Simple

library
    exposed-modules:
      Library.ExampleModule1
      Library.ExampleModule2

    build-depends:
      base >= 4 && < 5

    default-language: Haskell2010

    ghc-options: -O2 -Wall -fwarn-tabs

executable "example"
    build-depends:
        base >= 4 && < 5,
        mylibrary == 0.1
    default-language: Haskell2010
    main-is: Main.hs

Test-Suite test
  type: exitcode-stdio-1.0
  main-is: Test.hs
  default-language: Haskell2010
  build-depends:
      base >= 4 && < 5,
      mylibrary == 0.1
```

在沙盒中运行包中的可执行项，执行如下命令：

```bash
$ cabal run
$ cabal run <name>
```

在沙盒中加载库到GHCi中，执行如下命令：

```bash
$ cabal repl
$ cabal repl <name>
```

其中，``<name>``是cabal文件中的可执行项或库的声明名称。如有重名，可以用``exe:<name>``
或``lib:<name>``消除歧义。

要在本地构建包到``./dist/build``文件夹，执行cabal的build命令：

```bash
$ cabal build
```

要运行测试，必须使用``--enable-tests``重新配置包；在Test-Suite中的``build-depends``指定的包，
如果没有安装，也必须要手动安装。

```bash
$ cabal install --only-dependencies --enable-tests
$ cabal configure --enable-tests
$ cabal test
$ cabal test <name>
```

另外，可以在执行任意shell命令时使用为sandbox设置的环境变量。
通常是新开一个shell来让ghc和ghci类的命令使用沙盒（默认情况下这些命令不会识别沙盒配置）。

```bash
$ cabal exec
$ cabal exec sh # launch a shell with GHC sandbox path set.
```

通过``haddock``命令可以为本地项目构建haddock文档。这些文档会放到``./dist``目录下。

```bash
$ cabal haddock
```

如果我们已经注册了Hackage账号，就可以准备上传了。执行下面的命令来构建tarball和上传：

```bash
$ cabal sdist
$ cabal upload dist/mylibrary-0.1.tar.gz
```

有时可能需要从本地项目中添加库到沙盒中。此时可以使用add-source命令：

```bash
$ cabal sandbox add-source /path/to/project
```

使用freeze命令冻结当前包的各种依赖关系：

```bash
$ cabal freeze
```

此时会创建一个``cabal.config``文件，包含了各种依赖项：

```haskell
constraints: mtl ==2.2.1,
             text ==1.1.1.3,
             transformers ==0.4.1.0
```

虽然一般更倾向于使用``cabal repl``和``cabal run``命令，不过有时可能希望手动执行等价的操作。
下面是几个基于shell目录展开规则的命令别名。使用它们可以找到当前工作目录下的包库，同时使用合适的参数启动GHC：

```bash
alias ghc-sandbox="ghc -no-user-package-db -package-db .cabal-sandbox/*-packages.conf.d"
alias ghci-sandbox="ghci -no-user-package-db -package-db .cabal-sandbox/*-packages.conf.d"
alias runhaskell-sandbox="runhaskell -no-user-package-db -package-db .cabal-sandbox/*-packages.conf.d"
```

使用下面的zsh脚本可以查看当前工作目录中沙盒是否存在：

```bash
function cabal_sandbox_info() {
    cabal_files=(*.cabal(N))
    if [ $#cabal_files -gt 0 ]; then
        if [ -f cabal.sandbox.config ]; then
            echo "%{$fg[green]%}sandboxed%{$reset_color%}"
        else
            echo "%{$fg[red]%}not sandboxed%{$reset_color%}"
        fi
    fi
}

RPROMPT="\$(cabal_sandbox_info) $RPROMPT"
```

cabal的配置在``$HOME/.cabal/config``处，其中包含了各种配置，包括上传到Hackage所需的授权信息。
还可以通过配置完全禁止在沙盒之外安装包，从而避免产生冲突：

```perl
-- 禁止安装全局包
require-sandbox: True
```

通过下面的配置可以在编译library时收集运行时性能信息：

```perl
library-profiling: True
```

在“并发和性能分析”一节中会作更多介绍。

另一个常用的开关是``documentation``，强制本地构建Haddock文档，供离线查阅。在Linux系统上，
文档会被构建到``/usr/share/doc/ghc/html/libraries/``中。
（译者注：这个目录取决于发行版。以我的机器为例，是在``/usr/share/doc/ghc-7.10.2/html/libraries/``处）

```perl
documentation: True
```

如果安装了GHC，则可以通过下面的链接访问Prelude和Base的文档：

[/usr/share/doc/ghc/html/libraries/index.html](file:///usr/share/doc/ghc/html/libraries/index.html)
（译者注：同上，取决于发行版，以我的机器为例，是在``/usr/share/doc/ghc-7.10.2/html/libraries/index.html``处）

参见:

* [An Introduction to Cabal Sandboxes](http://coldwa.st/e/blog/2013-08-20-Cabal-sandbox.html)
* [Storage and Identification of Cabalized Packages](http://www.vex.net/~trebla/haskell/sicp.xhtml)

Hackage
-------

Hackage是事实上的开源Haskell包集结地。作为一种“过渡语言”（译者注：原谅是transitional language。不太确定是啥意思_(:з」∠)_），
Hackage给人们带来了诸多好处。其中流传着两个重要思想：

**可复用的代码/构件**

这种思想认为：库应该是稳定的、社区支持的构件，其他人可以在此基础上构建更高级的功能。
作者写库用以包装他们对某个问题域的理解，以便于其他人以此基础进行开发。

**临时区域/请求他人提供评论**

这种思想认为：Hackage是一个让人们上传实验用的类库的地方，作者通过这种方式开放源代码和得到社区的反馈。
但有时候作者把作品放上去，不加任何说明，之后解释说要干掉重做，导致很多Hackage中很多名称被烂尾的代码污染。


很多其他语言的生态环境（如Python、NodeJS、Ruby）倾向于前面一种哲学，但是到Haskell这里，
看到**成千上万的库完全没有文档和说明**，可能感觉很不爽。关于两种思想的差异和当前Hackage对污染行为的
容忍度目前还没有明确的答案。

不消说，目前有很多品质低劣的Haskell代码和文档。如何能够审慎地作出选择，摒弃糟粕，也是一门学问。

可以参考经验法则：如果这个库的Haddock文档里没有**最小可用示例**，通常就可以认定是一个单纯收集意见
（译者注：原文是RFC-style）的库，尽量别用。

有几位牛人做出来的库，一般都可以假定是稳定可用的，包括但不限于：

* Bryan O'Sullivan
* Johan Tibell
* Simon Marlow
* Gabriel Gonzalez
* Roman Leshchinskiy

GHCi
----

GHCi是GHC编译器的交互式shell环境。我们会把大半时间都花在这里。

命令        快捷键      动作
---------  ---------  --------------------------
`:reload`  `:r`       重新加载代码
`:type`    `:t`       调查类型
`:kind`    `:k`       调查类型构造器的类型
`:info`    `:i`       查看详细信息
`:print`   `:p`       打印表达式
`:edit`    `:e`       用系统默认编辑器打开文件

上面有关自省的命令对于调试和操作Haskell代码是至关重要的：

```haskell
λ: :type 3
3 :: Num a => a
```

```haskell
λ: :kind Either
Either :: * -> * -> *
```

```haskell
λ: :info Functor
class Functor f where
  fmap :: (a -> b) -> f a -> f b
  (<$) :: a -> f b -> f a
        -- Defined in `GHC.Base'
  ...
```

```haskell
λ: :i (:)
data [] a = ... | a : [a]       -- Defined in `GHC.Types'
infixr 5 :
```

也可以获得当前的全局环境状态，如模块级的变量绑定和类型：

```haskell
λ: :browse
λ: :show bindings
```

或模块级的导入：

```haskell
λ: :show imports
import Prelude -- implicit
import Data.Eq
import Control.Monad
```

或编译器级别的开关和杂注：

```haskell
λ: :set
options currently set: none.
base language is: Haskell2010
with the following modifiers:
  -XNoDatatypeContexts
  -XNondecreasingIndentation
GHCi-specific dynamic flag settings:
other dynamic, non-language, flag settings:
  -fimplicit-import-qualified
warning settings:

λ: :showi language
base language is: Haskell2010
with the following modifiers:
  -XNoDatatypeContexts
  -XNondecreasingIndentation
  -XExtendedDefaultRules
```

可以在提示符下设置语言扩展和编译器杂注。
[开关参考](http://www.haskell.org/ghc/docs/latest/html/users_guide/flag-reference.html)
中包含了大量编译器开关选项说明。下面列举几个常用开关：

```haskell
:set -XNoMonomorphismRestriction  # 同态限定(译者注：https://wiki.haskell.org/Monomorphism_restriction)
:set -fno-warn-unused-do-bind  # 屏蔽对未使用的do产生的警告
```

下面是几个交互选项的短名：

        功能
------  ---------
``+t``  显示表达式求值后的类型
``+s``  显示时间和内存使用状况
``+m``  启用多行表达式，相当于自动被``:{``和``:}``限定


```haskell
λ: :set +t
λ: []
[]
it :: [a]
```

```haskell
λ: :set +s
λ: foldr (+) 0 [1..25]
325
it :: Prelude.Integer
(0.02 secs, 4900952 bytes)
```

```haskell
λ: :{
λ:| let foo = do
λ:|           putStrLn "hello ghci"
λ:| :}
λ: foo
"hello ghci"
```

可以在``$HOME/.ghc/ghci.conf``或当前工作目录中的``./.ghci.conf``文件中对GHCi进行全局配置。

举例：在GHCi中添加一条命令在Hoogle中搜索类型。

```bash
cabal install hoogle
```

在``ghci.conf``中添加命令：


~~~~ {.haskell include="src/01-basics/ghci.conf"}
~~~~

```haskell
λ: :hoogle (a -> b) -> f a -> f b
Data.Traversable fmapDefault :: Traversable t => (a -> b) -> t a -> t b
Prelude fmap :: Functor f => (a -> b) -> f a -> f b
```

如果你喜欢装逼，可以把你的GHC提示符设成``λ``或``ΠΣ``：

```haskell
:set prompt "λ: "
:set prompt "ΠΣ: "
```

编辑器集成
------------------

Haskell有大量的编辑器工具，可以提供交互式的提示信息，以及如子表达式类型查询、代码错误检查、
类型检查、自动补全等功能。

![](img/errors.png)

有很多供程序猿专用编辑器使用的开箱即用设置方案，可以迅速完成Haskell开发环境的配置。

**Vim**

https://github.com/begriffs/haskell-vim-now

**Emacs**

https://github.com/chrisdone/emacs-haskell-config

这些包幕后使用的工具通常都可以通过cabal来安装。

```haskell
cabal install hdevtools
cabal install ghc-mod
cabal install hlint
cabal install ghcid
cabal install ghci-ng
```

尤其是``ghc-mod``和``hdevtools``，可以显著提升开发效率。

参见：

* [A Vim + Haskell Workflow](http://www.stephendiehl.com/posts/vim_haskell.html)

底元素（Bottom）
-------

```haskell
error :: String -> a
undefined :: a
```

底元素是所有类型的唯一共有值。当对它求值时，按照Haskell的语义，不再输出任何有意义的值。
通常写作“⊥”。（意为编译器把你艹翻了）

下例为一个死循环。

```haskell
f :: a
f = let x = x in x
```

``undefined``函数是方便调试和编写不完整的程序的实用手段：

```haskell
f :: a -> Complicated Type
f = undefined -- 明天再写，先把类型检查过了
```

通过不完整模式匹配创建的部分函数可能是产生底元素的最常见原因：

```haskell
data F = A | B
case x of
  A -> ()
```

上面的代码将会翻译为下面的GHC Core代码，在模式匹配不到的条件处加入了一条异常。可以通过
``-fwarn-incomplete-patterns``和``-fwarn-incomplete-uni-patterns``
让GHC产生更详细的信息。

```haskell
case x of _ {
  A -> ();
  B -> patError "<interactive>:3:11-31|case"
}
```

同样的现象也发生于在创建记录数据时缺少域值。创建记录数据时缺少域值几乎肯定是错误的设计，
此时GHC默认产生警告。

```haskell
data Foo = Foo { example1 :: Int }
f = Foo {}
```

和上面一样，编译器会插入一条错误：

```haskell
Foo (recConError "<interactive>:4:9-12|a")
```

有一点可能不是非常明显：这种产生错误的方式在Prelude中大量使用，有一些有务实的理由，
而有一些则是历史原因。``head``函数是一个典型，其类型是``[a] -> a``。如果没有底元素，
则不可能实现为这种类型。

~~~~ {.haskell include="src/01-basics/bottoms.hs"}
~~~~

在生产环境中很少能看到这种部分函数被到处胡乱调用。推荐的做法是使用``Data.Maybe``中提供的安全版本
结合``maybe``和``either``函数，或使用模式匹配来实现。

```haskell
listToMaybe :: [a] -> Maybe a
listToMaybe []     =  Nothing
listToMaybe (a:_)  =  Just a
```

当调用一个由错误来定义的底元素时，通常不会生成出错位置信息，但可以在``undefined``或``error``处
通过短路逻辑调用``assert``函数，从而获得位置信息。

~~~~ {.haskell include="src/01-basics/fail.hs"}
~~~~

参见: [Avoiding Partial Functions](https://wiki.haskell.org/Avoiding_partial_functions)

模式完整度
--------------

Haskell允许不完整的模式匹配和case子句。（TODO: or cases which are not exhaustive and instead
of yielding a value diverge）

通过不完整模式或case子句编写部分函数是存在争议的，大量使用不完整模式是危险讯号，从语言中完全移除这个功能
却也显得过于严格，导致很多合法的程序都失效了。

比如，下面的函数当接收Nothing参数时会导致运行时崩溃。然后它是一个类型检查良好的合法程序。

```haskell
unsafe (Just x) = x + 1
```

编译器支持某些特定的开关，可以针对不完整模式和case子句局部或全局地启用警告，甚至完全禁止。

```haskell
$ ghc -c -Wall -Werror A.hs
A.hs:3:1:
    Warning: Pattern match(es) are non-exhaustive
             In an equation for `unsafe': Patterns not matched: Nothing
```

使用``OPTIONS_GHC``杂注，可以在模块级别启用``-Wall``和不完整模式相关的开关，

```haskell
{-# OPTIONS_GHC -Wall #-}
{-# OPTIONS_GHC -fwarn-incomplete-patterns #-}
```

一个更难以察觉的例子是在lambda表达式中隐式地使用“单模式”时。下面的代码在接收Nothing参数时会崩掉：

```haskell
boom = \(Just a) -> something
```

这种情况常发生在let或do块中，当把块按规则展开后得到上述的lambda表达式时：

```haskell
boom = let
  Just a = something

boom = do
  Just a <- something
```

可以通过``-fwarn-incomplete-uni-patterns``开关让GHC产生警告。

粗略地说，任何稍微大型的程序都会或多或少地用到部分函数。没办法事实就是如此。这就意味着在Haskell
的类型系统无法顾及的一些场合，程序员必须守好贞操。不过也有一些尚待发展的项目，如LiquidHaskell，可
能通过更为精细的类型系统解决上述矛盾。尽管如此，这还是个值得探讨的话题。

调试器
--------

GHCi提供了内置的调试器，虽然比较少用。调试由底元素导致的未捕获的异常和异步异常，与用gdb调试段错误差不多。

```haskell
λ: :set -fbreak-on-exception
λ: :trace main
λ: :hist
λ: :back
```

调用栈追踪
-----------

可以通过打开一个特殊的开关和性能分析选项，让GHC在执行底元素（error, undefined）时打印调用栈。
这两个选项默认是关闭的。如：

~~~~ {.haskell include="src/01-basics/stacktrace.hs"}
~~~~

```haskell
$ ghc -O0 -rtsopts=all -prof -auto-all --make stacktrace.hs
./stacktrace +RTS -xc
```

这时运行时告诉我们异常发生在函数``g``中，并显示调用栈层次。

```haskell
*** Exception (reporting due to +RTS -xc): (THUNK_2_0), stack trace:
  Main.g,
  called from Main.f,
  called from Main.main,
  called from Main.CAF
  --> evaluated by: Main.main,
  called from Main.CAF
```

运行的时候最好不要开启优化选项（相当于``-O0``），这样可以保留最原始的调用栈结构。如果开启了优化，
栈结构可能完全不同，因为GHC会用各种丧心病狂的方式重组程序。

参见:

* [xc flag](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/runtime-control.html#idp13041968)

跟踪调试
-----

Haskell纯函数的特性使大部分代码可以自省，因此一般不太需要"printf"风格的调试手段，只需打开
GHCi测试一下函数就行了。不过Haskell还是提供了一个不安全的``trace``函数，可以在IO monad之外
的任何地方打印结果。

~~~~ {.haskell include="src/01-basics/trace.hs"}
~~~~

这个函数不是纯函数（内部使用了``unsafePerformIO``），因此不应在稳定代码中使用。

除了直接使用trace函数，还有几种常用的单子化模式。

```haskell
import Text.Printf
import Debug.Trace

traceM :: (Monad m) => String -> m ()
traceM string = trace string $ return ()

traceShowM :: (Show a, Monad m) => a -> m ()
traceShowM = traceM . show

tracePrintfM :: (Monad m, PrintfArg a) => String -> a -> m ()
tracePrintfM s = traceM . printf s
```

类型化占位符
-----------

从GHC 7.8开始我们可以使用一种新的工具来调试不完整的程序——*类型化占位符*。在声明右侧的任意值处用
“_”替代，GHC会在类型检查时产生错误，并显示出可以让程序通过类型检查的可能值。

```haskell
instance Functor [] where
  fmap f (x:xs) = f x : fmap f _
```

```bash
[1 of 1] Compiling Main             ( src/typedhole.hs, interpreted )

src/typedhole.hs:7:32:
    Found hole ‘_’ with type: [a]
    Where: ‘a’ is a rigid type variable bound by
               the type signature for fmap :: (a -> b) -> [a] -> [b]
               at src/typedhole.hs:7:3
    Relevant bindings include
      xs :: [a] (bound at src/typedhole.hs:7:13)
      x :: a (bound at src/typedhole.hs:7:11)
      f :: a -> b (bound at src/typedhole.hs:7:8)
      fmap :: (a -> b) -> [a] -> [b] (bound at src/typedhole.hs:7:3)
    In the second argument of ‘fmap’, namely ‘_’
    In the second argument of ‘(:)’, namely ‘fmap f _’
    In the expression: f x : fmap f _
Failed, modules loaded: none.
```

由此可见，GHC正确指示出了完成代码所需的表达式是``xs :: [a]``。

Nix
---

Nix是比cabal更加宏观的包管理系统。它不是一个单纯面向Haskell的项目，不过开发者们为了让它和现有的
cabal框架集成也花了不少心思。*Nix不是cabal的替代品*，但可以用来接管cabal的部分功能：使用Nix
创建的隔离环境中可以包含以二进制方式安装的Haskell库，也可以包含任意的系统库，从而链接到编译出来的
Haskell程序中。

是否应该使用Nix也是颇具争议的：使用Nix相当于使用了更重型的系统，还需要用Nix的特殊语言写一系列
额外的配置文件。Haskell和Nix的发展道路还有很多未知，而且还不清楚Nix究竟是绕过了cabal现有的一些缺点
还是提供了更深层次的统一模型。

装好NixOS包管理器之后（译者注：其实Nix就是NixOS的包管理器），就可以打开nix shell，并
访问NixOS仓库里装好的各种包。

```bash
$ nix-shell -p haskellPackages.parsec -p haskellPackages.mtl --command ghci
```

显然上面的命令不仅适用于Haskell包，还适用于很多其他的二进制包和库。如果你的库依赖于某个特定版本的
包，比如GNU readline，Nix可以处理这种依赖关系，而用``cabal-install``显然是处理不了此类关系的。

```bash
$ nix-shell -p llvm -p julia -p emacs
```

用Nix处理Haskell包的工作流程包含如下操作：

```bash
$ cabal init
... usual setup ...
$ cabal2nix mylibrary.cabal --sha256=0 > shell.nix
```

上述命令会生成类似下面的文件：

```ocaml
# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, mtl, transformers
}:

cabal.mkDerivation (self: {
  pname = "mylibrary";
  version = "0.1.0.0";
  sha256 = "0";
  isLibrary = true;
  isExecutable = true;
  buildDepends = [
    mtl transformers
  ];
})
```

我们需要手动修改这个文件：

```ocaml
# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ haskellPackages ? (import <nixpkgs> {}).haskellPackages }:

haskellPackages.cabal.mkDerivation (self: {
  pname = "mylibrary";
  version = "0.1.0.0";
  src = "./.";
  isLibrary = true;
  isExecutable = true;
  buildDepends = with haskellPackages; [
    mtl transformers
  ];
  buildTools = with haskellPackages; [ cabalInstall ];
})

```

然后，你就可以可以通过下面的命令打开你项目的cabal repl环境。

```bash
$ nix-shell --command "cabal repl"
```

还可以用一个叫cabal2nix4dev的库自动处理上述过程。

参见：

* [cabal2nix4dev](https://github.com/dave4420/cabal2nix4dev)

Haddock
-------

Haddock是Haskell源代码的文档化工具，它与cabal工具链可以很好地集成。

```haskell
-- | f 的文档
f :: a -> a
f = ...
```

```haskell
-- | 带有多个参数的函数 f 的。。。。。。。。
-- 多行文档
fmap :: Functor f =>
     => (a -> b)  -- ^ 函数
     -> f a       -- ^ 输入
     -> f b       -- ^ 输出
```

```haskell
data T a b
  = A a -- ^ A 的文档
  | B b -- ^ B 的文档
```

对于模块中的元素（值、类型、类型类），可以通过将标识符放入单引号“'”之中来创建超链接。

```haskell
data T a b
  = A a -- ^ 'A' 的文档
  | B b -- ^ 'B' 的文档
```

将模块名放入双引号“"”之中，可以创建到模块的超链接。

```haskell
-- | 此处使用了 "Data.Text" 库，并导入了
-- 'Data.Text.pack' 函数。
```

```haskell
-- | 下面创建了一个语句块.
--
-- @
--    f x = f (f x)
-- @

-- > f x = f (f x)
```

```haskell
-- | 下面是一个交互式shell的例子。
--
-- >>> factorial 5
-- 120
```

可以通过在模块注释前面加星号“*”来创建标题。

```haskell
module Foo (
  -- * My Header
  example1,
  example2
)
```

可以在段落前加上``$``块来在别处引用它。

```haskell
module Foo (
  -- $section1
  example1,
  example2
)

-- $section1
-- Here is the documentation section that describes the symbols
-- 'example1' and 'example2'.
```

使用下面的语法来创建链接：

```haskell
<url text>
```

也可以包含图片，路径必须相对于haddock文档，或者是绝对路径。


```haskell
<<diagram.png title>>
```

也可以在代码中使用杂注来控制Haddock选项，既可以是项目级也可以是模块级。


```haskell
{-# OPTIONS_HADDOCK show-extensions, ignore-exports #-}
```

选项              描述
------           -------------------------------
ignore-exports   无视导出列表，包含当前域中的所有签名
not-home         模块不会被用作元素的首要链接点
                 （译者注：原文是Module will not be considered in the root documentation. 似乎有误，
                 参见[此处](https://www.haskell.org/haddock/doc/html/hyperlinking.html)）
show-extensions  在文档中注明所使用的语言扩展
hide             强制从Haddock中屏蔽模块
prune            屏蔽缺少文档的定义


单子（Monad）
======

单子修真八要
------------------------------

许多人花了大量笔墨渲染单子的神秘之处。 于是我总结了一条单子修真的成功之路：

1. 别去读那些流传的单子系列教程
2. 再强调一遍，千万别去读那些教程
3. 研习Haskell中的类型
4. 学习类型类
5. 阅读[Typeclassopedia（类型类百科）](http://wiki.haskell.org/Typeclassopedia).
6. 阅读单子的定义
7. 在实际代码中使用单子
8. 别写任何基于类比的单子教程

换句话说，要想理解单子，唯一途径是直接读代码，打开GHC，再写一些代码。任何类比和隐喻的手法
都不会帮助你理解单子。


单子之谜
-------------

下列陈述全部是**假命题**：

* 单子是不纯的。
* 单子和副作用有关。
* 单子和状态有关。
* 单子和指令序列有关。
* 单子和IO有关。
* 单子依赖于惰性。
* 单子是让Haskell产生副作用的“后门”。
* 单子是Haskell中内嵌的命令式语言。
* 使用单子需要理解抽象数学。

参见: [What a Monad Is Not（破除单子谎言）](http://wiki.haskell.org/What_a_Monad_is_not)

单子三大定律
----

单子并不复杂，它仅仅是一个类型类，其中包含两个函数：``(>>=)``（读作“绑定”）和``return``。
值得一提的是，这里的"return"和你以往所熟悉的概念完全不同。你必须抛弃对它的先入之见才能理解。


```haskell
class Monad m where
  (>>=)  :: m a -> (a -> m b) -> m b
  return :: a -> m a
```

除此之外，所有单子还必须满足以下三大定律：

**定律1**

```haskell
return a >>= f ≡ f a
```

**定律2**

```haskell
m >>= return ≡ m
```

**定律3**

```haskell
(m >>= f) >>= g ≡ m >>= (\x -> f x >>= g)
```

还有一个通过``(>>=)``定义的辅助函数``(>>)``，和``(>>=)``基本相同，但舍弃了参数。

```haskell
(>>) :: Monad m => m a -> m b -> m b
m >> k = m >>= \_ -> k
```

参见: [Monad Laws](http://wiki.haskell.org/Monad_laws)

do标记法
-----------

在Haskell中，可以使用语法糖写成完全等价于直接应用单子操作的形式。脱糖规则依照如下定义递归进行：

```haskell
do { a <- f ; m } ≡ f >>= \a -> do { m }
do { f ; m } ≡ f >> do { m }
do { m } ≡ m
```

下例三种写法是等价的：

```haskell
do
  a <- f
  b <- g
  c <- h
  return (a, b, c)

do {
  a <- f ;
  b <- g ;
  c <- h ;
  return (a, b, c)
}

f >>= \a ->
  g >>= \b ->
    h >>= \c ->
      return (a, b, c)
```

若将绑定操作写成非柯里化函数的形式（注意这并不是Haskell中的使用方式），以上的脱糖步骤
可能会写成下面这种带有lambda表达式的嵌套链式结构。

```haskell
bindMonad(f, lambda a:
  bindMonad(g, lambda b:
    bindMonad(h, lambda c:
      returnMonad (a,b,c))))
```

在do标记法中，单子定律可以等价地写作：

**定律1**

```haskell
  do x <- m
     return x

= do m
```

**定律2**

```haskell
  do y <- return x
     f y

= do f x
```

**定律3**

```haskell
  do b <- do a <- m
             f a
     g b

= do a <- m
     b <- f a
     g b

= do a <- m
     do b <- f a
        g b
```

参见: [Haskell 2010: Do Expressions](http://www.haskell.org/onlinereport/haskell2010/haskellch3.html#x8-470003.14)

Maybe
-----

*Maybe*是最简单的单子实例之一，用于表示失败的计算过程。

```haskell
data Maybe a = Just a | Nothing
```

```haskell
instance Monad Maybe where
  (Just x) >>= k = k x
  Nothing  >>= k = Nothing

  return = Just
```

```haskell
(Just 3) >>= (\x -> return (x + 1))
-- Just 4

Nothing >>= (\x -> return (x + 1))
-- Nothing

return 4 :: Maybe Int
-- Just 4
```

~~~~ {.haskell include="src/02-monads/maybe.hs"}
~~~~

List
----

*List*是另一个最简单的单子实例。

```haskell
instance Monad [] where
  m >>= f   =  concat (map f m)
  return x  =  [x]
```

例如：

```haskell
m = [1,2,3,4]
f = \x -> [1,0]
```

求值过程如下：

```haskell
m >>= f
==> [1,2,3,4] >>= \x -> [1,0]
==> concat (map (\x -> [1,0]) [1,2,3,4])
==> concat ([[1,0],[1,0],[1,0],[1,0]])
==> [1,0,1,0,1,0,1,0]
```

Haskell中的列表推导式可以用单子形式实现：

```haskell
a = [f x y | x <- xs, y <- ys, x == y ]

-- 等同于`a`
b = do
  x <- xs
  y <- ys
  guard $ x == y
  return $ f x y
```

~~~~ {.haskell include="src/02-monads/list.hs"}
~~~~

IO
--

``IO a``类型值代表了一种计算，当执行时会执行某些I/O操作，最终返回一个``a``类型的值。
下面是一个IO单子的脱糖过程：

```haskell
main :: IO ()
main = do putStrLn "What is your name: "
          name <- getLine
          putStrLn name
```

```haskell
main :: IO ()
main = putStrLn "What is your name:" >>=
       \_    -> getLine >>=
       \name -> putStrLn name
```

```haskell
main :: IO ()
main = putStrLn "What is your name: " >> (getLine >>= (\name -> putStrLn name))
```

参见: [Haskell 2010: Basic/Input Output](http://www.haskell.org/onlinereport/haskell2010/haskellch7.html)

到底想表达什么？
----------------

不知你有没有发现，我们已经为三个开发过程中截然不同的核心概念——*失败*、*集合*、*副作用*找到了一个统一接口。

我们来写一个新的函数``sequence``，它包装了函数``mcons``，``mcons``类似列表构造函数
（亦即``(a : b : [])``），区别在于它是通过绑定方法从两个单子值中取出构造函数的参数：

```haskell
sequence :: Monad m => [m a] -> m [a]
sequence = foldr mcons (return [])

mcons :: Monad m => m t -> m [t] -> m [t]
mcons p q = do
  x <- p
  y <- q
  return (x:y)
```

这个函数对于我们上面讨论的单子类型分别有什么作用？

**Maybe**

对于一个``Maybe``值的列表执行``sequence``操作，可以收集到计算序列的结果，前提是所有的计算必须全部成功。

```haskell
sequence :: [Maybe a] -> Maybe [a]
```

```haskell
sequence [Just 3, Just 4]
-- Just [3,4]
sequence [Just 3, Just 4, Nothing]
-- Nothing
```

**List**

对于列表单子执行绑定操作，会从两个列表操作数中生成两两成对的结果，因此，通过``sequence``对包含n个列表的列表执行折叠（fold）操作相当于n个列表的笛卡尔积。

```haskell
sequence :: [[a]] -> [[a]]
```

```haskell
sequence [[1,2,3],[10,20,30]]
-- [[1,10],[1,20],[1,30],[2,10],[2,20],[2,30],[3,10],[3,20],[3,30]]
```

**IO**

对IO操作执行``sequence``，会依次执行这些操作，并依序返回每个操作的结果列表。

```haskell
sequence :: [IO a] -> IO [a]
```

```haskell
sequence [getLine, getLine]
-- a
-- b
-- ["a","b"]
```

我们可以得出结论，虽然这三种编程中的基本概念一般是分别定义的，实际上可以通过这种相似的结构抽象出来并复用，
以构建更高层次的抽象系统，对于所有的现有和以后可能的实现都很好用。如果你想找一个必须理解单子的理由，这便是你要找的理由。
现在回过头来看，这不就是我当时百思不得解的单子的精髓嘛！

参见: [Control.Monad](http://hackage.haskell.org/package/base-4.6.0.1/docs/Control-Monad.html#g:4)

Reader单子
------------

Reader单子允许我们在单子上下文中访问共享的不变状态。

```haskell
ask :: Reader r r
asks :: (r -> a) -> Reader r a
local :: (r -> r) -> Reader r a -> Reader r a
runReader :: Reader r a -> r -> a
```

~~~~ {.haskell include="src/02-monads/reader.hs"}
~~~~

Reader单子的一个简单实现：

~~~~ {.haskell include="src/02-monads/reader_impl.hs"}
~~~~

Writer单子
------------

Writer单子允许我们在单子上下文中写入惰性值流。

```haskell
tell :: w -> Writer w ()
execWriter :: Writer w a -> w
runWriter :: Writer w a -> (a, w)
```

~~~~ {.haskell include="src/02-monads/writer.hs"}
~~~~

Writer单子的一个简单实现：

~~~~ {.haskell include="src/02-monads/writer_impl.hs"}
~~~~


这个实现是惰性的，因此你必须清楚是否真的希望得到生成次程式（thunk）流：很多情况下你的计算确实需要从``runWriter``中读取次程式流，
但也有很多情况要求调用``runWriter``时通过直接求值来获取有限的值流。如果你不是有意要利用Writer的惰性，就会非常悲催，不过改起来也并不困难。

State单子
-----------

State单子允许在状态单子上下文中访问和修改共享状态。

```haskell
runState  :: State s a -> s -> (a, s)
evalState :: State s a -> s -> a
execState :: State s a -> s -> s
```

~~~~ {.haskell include="src/02-monads/state.hs"}
~~~~

关于State单子常常有一种误解，认为它是不纯的，其实它完完全全是纯的。即使你不用，通过显式地传递状态，一样可以得出相同的结果。
下面是State单子的一个简单实现，仅需几行代码：

~~~~ {.haskell include="src/02-monads/state_impl.hs"}
~~~~

单子教程相关
---------------

So many monad tutorials have been written that it begs the question, what makes
monads so difficult when first learning Haskell. I suggest there are three
aspects to why this is so:
为什么单子对于Haskell初学者如此难以掌握？我们看过太多太多有关单子的教程完全回避了这个问题。
我认为有以下三个原因：

1. *关于do标记法的脱糖方法往往一笔带过甚至避而不谈*

我们写的很多Haskell代码在底层会经历复杂的重组过程，并转换为完全不同的形式。

Most monad tutorials will not manually expand out the do-sugar. This leaves the
beginner thinking that monads are a way of dropping into a pseudo-imperative
language inside of code and further fuels that misconception that specific
instances like IO are monads in their full generality.
大多有关单子的教程不会手工操作一遍do标记法的展开过程，于是给初学者留下了这样的印象，认为单子是在代码中临时陷入伪命令式代码的方式，
甚至造成更深的误解，认为诸如IO的单子实例就是单子的全部意义。


```haskell
main = do
  x <- getLine
  putStrLn x
  return ()
```

必须知道如何手工脱糖，才能领会单子的奥妙。

```haskell
main =
  getLine >>= \x ->
    putStrLn x >>= \_ ->
      return ()
```

2. *其他语言中很少对高阶函数使用不对称的二元中缀运算符*

```haskell
(>>=) :: Monad m => m a -> (a -> m b) -> m b
```

运算符左边是一个``m a``类型的数据，而右边是``a -> m b``类型的函数。虽然某些语言中也有
用作高阶函数的中缀运算符，但仍然比较少见。

So with a function desugared, it can be confusing that ``(>>=)`` operator is in
fact building up a much larger function by composing functions together.
因此，``(>>=)``运算符实际是把脱糖后的函数组合成更复杂的函数，这一点比较容易让人疑惑。

```haskell
main =
  getLine >>= \x ->
    putStrLn >>= \_ ->
      return ()
```

写成前缀形式会比较容易理解：

```haskell
main =
  (>>=) getLine (\x ->
    (>>=) putStrLn (\_ ->
          return ()
    )
  )
```

可能对于从其他语言过渡来的童鞋们来说，把运算符直接拿掉看起来更清楚一些。

```haskell
main = bind getLine (\x -> bind putStrLn (\_ -> return ()))
  where
    bind x y = x >>= y
```

3. *特殊的类型类字典参数的多态在其他语言中也很少见*

Haskell中的重载实现对于对类型推断不太熟悉的人来说可能并不直观。实际上``(>>=)``或``bind``函数有三个参数，
有一个额外的参数是类型类的字典（``$dMonad``），只不过它是隐式传递的，从用户层面来说已经被抽象掉了。

```haskell
main $dMonad = bind $dMonad getLine (\x -> bind $dMonad putStrLn (\_ -> return $dMonad ()))
```

只不过在这个例子中，单子类型类参数是同一个实例（通过类型推断得知）（译者注：都是IO）。
因此，类型类实例的字典（``$dMonadIO``）自始至终都是同一个。

```haskell
main :: IO ()
main = bind $dMonadIO getLine (\x -> bind $dMonadIO putStrLn (\_ -> return $dMonadIO ()))
```

一般不会对转换过程作出讨论，而一旦我们真正领会了转换过程内在的逻辑，就可以信手拈来。
我觉得单子教程普遍存在的根本错误并不是对单子的直观感受难以表述清晰（不要用类比或隐喻的手法！），而是
初学者们学习单子时没有对上面的(1)、(2)、(3)点有足够深刻的认识（TODO: and then trip on the simple fact that
monads are the first example of a Haskell construct that is the confluence of all three.）

参见: [单子教程的普遍谬误](http://byorgey.wordpress.com/2009/01/12/abstraction-intuition-and-the-monad-tutorial-fallacy/)

单子转换器（Monad Transformers）
==================

mtl库 / transformers库
------------------

好吧，很抱歉，其实上一章中有关单子的一些描述不够准确。目前流行的Haskell单子库一般都以一种更为通用的方式编写：
单子转换器。它可以将多个单子进行组合形成新的单子。之前说到的那些单子实际上单子转换器的一种特殊形式，是由单子转换器加
Identify单子复合而成的。

单子     转换器        类型            转换后的类型
------  -----------  --------------- -------------------
Maybe   MaybeT       ``Maybe a``     ``m (Maybe a)``
Reader  ReaderT      ``r -> a``      ``r -> m a``
Writer  WriterT      ``(a,w)``       ``m (a,w)``
State   StateT       ``s -> (a,s)``  ``s -> m (a,s)``


```haskell
type State  s = StateT  s Identity
type Writer w = WriterT w Identity
type Reader r = ReaderT r Identity

instance Monad m => MonadState s (StateT s m)
instance Monad m => MonadReader r (ReaderT r m)
instance (Monoid w, Monad m) => MonadWriter w (WriterT w m)
```

mtl库是这些单子最常见的通用接口。mtl库本身依赖transformers库，它负责把之前提到的基本单子泛化为转换器形式。

转换器
------------

从根本上来说，单子转换器提供了将多个单子化计算过程嵌套为栈的功能，并提供了一个接口（``lift``）以便在不同层级间交换数据。

```haskell
lift :: (Monad m, MonadTrans t) => m a -> t m a
liftIO :: MonadIO m => IO a -> m a
```

```haskell
class MonadTrans t where
    lift :: Monad m => m a -> t m a

class (Monad m) => MonadIO m where
    liftIO :: IO a -> m a

instance MonadIO IO where
    liftIO = id
```

和单子一样，单子转换器也遵循几个定律。

**定律1**

```haskell
lift . return = return
```

**定律2**

```haskell
lift (m >>= f) = lift m >>= (lift . f)
```

或等价地：

**1**

```haskell
  lift (return x)

= return x
```

**2**

```haskell
  do x <- lift m
     lift (f x)

= lift $ do x <- m
            f x
```

值得记住的是，单子转换器的组合过程由外而内进行，展开过程由内而外进行。

![](img/transformer_unroll.png)

参见: [Monad Transformers: Step-By-Step](http://www.cs.virginia.edu/~wh5a/personal/Transformers.pdf)

ReaderT
-------

比如说，Reader单子有三种形式，第一种是Haskell 98版的实现，已经弃用，但是适于说明。另外两种分别是*transformers*变体和*mtl*变体

*Reader*

```haskell
newtype Reader r a = Reader { runReader :: r -> a }

instance MonadReader r (Reader r) where
  ask       = Reader id
  local f m = Reader $ runReader m . f
```

*ReaderT*

```haskell
newtype ReaderT r m a = ReaderT { runReaderT :: r -> m a }

instance (Monad m) => Monad (ReaderT r m) where
  return a = ReaderT $ \_ -> return a
  m >>= k  = ReaderT $ \r -> do
      a <- runReaderT m r
      runReaderT (k a) r

instance MonadTrans (ReaderT r) where
    lift m = ReaderT $ \_ -> m
```

*MonadReader*

```haskell
class (Monad m) => MonadReader r m | m -> r where
  ask   :: m r
  local :: (r -> r) -> m a -> m a

instance (Monad m) => MonadReader r (ReaderT r m) where
  ask       = ReaderT return
  local f m = ReaderT $ \r -> runReaderT m (f r)
```

所以对应的三个``ask``版本应该是：

```haskell
ask :: Reader r a
ask :: Monad m => ReaderT r m r
ask :: MonadReader r m => m r
```

实践中，比较现代的Haskell代码只使用最后一种。

基础
------

最基本的用法是对外层的每个单子使用T版本的转换器，并显式地使用``lift``和``return``在层间交换数据。单子的类型构造器类型是``(* -> *)``，
因此，把单子变为新的单子的转换器的构造器类型应该是``((* -> *) -> * -> *)``

```haskell
Monad (m :: * -> *)
MonadTrans (t :: (* -> *) -> * -> *)
```

比如我们想同时使用Reader和Maybe单子构造一个复合的计算过程，我们可以把Maybe放到``ReaderT``中来组成一个``ReaderT t Maybe a``。

~~~~ {.haskell include="src/03-monad-transformers/transformer.hs"}
~~~~

这种方式最大的限制是我们会写出形似``lift.lift.lift``和``return.return.return``的代码。

Newtype类型类派生
----------------

使用newtype可以将一个具有单一构造函数的数据类型表示为一个独立的类型，并且与data不同的是，它没有运行时的性能损耗。在很多情景下，使用newtype
包装字符串和数值类型可以极大地减少意外错误。使用``-XGeneralizedNewtypeDeriving``可以重新取得内层类型实例的功能。

~~~~ {.haskell include="src/03-monad-transformers/newtype.hs"}
~~~~

```haskell
Couldn't match type `Double' with `Velocity'
Expected type: Velocity
  Actual type: Double
In the second argument of `(+)', namely `x'
In the expression: v + x
```

我们可以通过使用newtype派生mtl库中的类型类来创建平铺的转换器类型，再也不需要在转换栈中地调用``lift``了。比如下面这个虚拟机，
其中包含了Reader、Writer和State单子。

~~~~ {.haskell include="src/03-monad-transformers/newtype_deriving.hs"}
~~~~

对一个newtype构造器使用模式匹配在编译时不会生成相关代码，比如下面的代码中，``extractB``函数并不会匹配``MkB``构造函数，
因为``MkB``在运行时并不存在，仅仅是编译时的一个临时结构，而``extractA``则不同。

```haskell
data A = MkA Int
newtype B = MkB Int

extractA :: A -> Int
extractA (MkA x) = x

extractB :: B -> Int
extractB (MkB x) = x
```

效率
----------

单子转换器的第二条定律确保连续使用lift操作在语义上等同于将运算结果直接lift到外层单子。

```haskell
do x <- lift m  ==  lift $ do x <- m
   lift (f x)                 f x
```

虽然结果肯定是相同的，但是在不同单子层级间进行lift操作并不是毫无代价（and crops up frequently when working with the monad traversal
and looping functions.）。 比如，下面左边的三个函数在效率上较之右边来得差（which performs the bind in the base monad instead
of lifting on each iteration）。

```haskell
-- Less Efficient      More Efficient
forever (lift m)    == lift (forever m)
mapM_ (lift . f) xs == lift (mapM_ f xs)
forM_ xs (lift . f) == lift (forM_ xs f)
```

单子态射
---------------

```haskell
lift :: Monad m => m a -> t m a
```

```haskell
hoist :: Monad m => (forall a. m a -> n a) -> t m b -> t n b
embed :: Monad n => (forall a. m a -> t n a) -> t m b -> t n b
squash :: (Monad m, MMonad t) => t (t m) a -> t m a
```

TODO

参见: [mmorph](https://hackage.haskell.org/package/mmorph)

语言扩展
===================

It's important to distinguish between different categories of language extensions:
我们必须注意区分不同类别的语言扩展。

把扩展归分为**常用**和**专用**的过程本身带有非常严重的主观色彩。搞类型系统研究的和搞数据库的理解可能完全不同。所以下面的分类是一种保守的估计。
我们随便定一种分类标准，认为``FlexibleInstances``和``OverloadedStrings``是“常用的”，而``GADTs``和``TypeFamilies``是“专用的”。

**列头说明**

* *良性* 表示如果导入了扩展但并未使用，则不会对模块的语义产生影响。
* *历史* 表示不应使用，甚至强行使用会带来危险。保留这些扩展的的目的纯粹是为了向后兼容。

<extensions></extensions>

参见: [GHC Extension Reference](http://www.haskell.org/ghc/docs/7.8.2/html/users_guide/flag-reference.html#idp14615552)

良性扩展
----------

可能没办法一眼看出哪些扩展是最常用的，但可以肯定的是，下面这些扩展较为安全和被广泛使用。

* NoMonomorphismRestriction
* FlexibleContexts
* FlexibleInstances
* GeneralizedNewtypeDeriving
* GADTs
* FunctionalDependencies
* OverloadedStrings
* TypeSynonymInstances
* BangPatterns
* DeriveGeneric
* DeriveDataTypeable
* ScopedTypeVariables

危险扩展
-------------

GHC的类型检查器有时随意让你打开某些扩展，而这些扩展并不能真正解决问题，包括：

* DatatypeContexts
* OverlappingInstances
* IncoherentInstances
* ImpredicativeTypes

如果你需要启用这些扩展，那几乎一定是设计上的缺陷，不要听信GHC的建议而试图通过启用这些扩展来解决眼前的问题。

类型推断
---------

一般来说，Haskell的类型推断相当准确，但也存在一些可能导致问题的特殊情况。考虑下面两个函数：

**互递归绑定组**

```haskell
f x = const x g
g y = f 'A'
```

推导出来的类型在使用上没有问题，但是并不足够泛化。GHC先分析表达式之间的依赖关系，将他们分组，并用同一替换的方式确定类型。因此，推导出来的类型可能
不是最泛化的结果，此时你需要显式地指定类型。

```haskell
-- Inferred types
f :: Char -> Char
g :: t -> Char

-- Most general types
f :: a -> a
g :: a -> Char
```

**多态递归**

```haskell
data Tree a = Leaf | Bin a (Tree (a, a))

size Leaf = 0
size (Bin _ t) = 1 + 2 * size t
```

这段代码的问题在于``size``中的类型变量``a``跨越了两种类型（``a``和``(a,a)``）。这是一个多态递归。
类型检查器的occurs-check将会失败，推断出错误的类型。

```haskell
    Occurs check: cannot construct the infinite type: t0 = (t0, t0)
    Expected type: Tree t0
      Actual type: Tree (t0, t0)
    In the first argument of `size', namely `t'
    In the second argument of `(*)', namely `size t'
    In the second argument of `(+)', namely `2 * size t'
```

Simply adding an explicit type signature corrects this. Type inference using polymorphic recursion is
undecidable in the general case.
加上的类型签名就可以解决问题。一般情况下多态递归形式的类型推断是不可判定的。

```haskell
size :: Tree a -> Int
size Leaf = 0
size (Bin _ t) = 1 + 2 * size t
```

参见: [Static Semantics of Function and Pattern Bindings](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html#x10-880004.5)

单态限定
------------------------

类型推断有一种常见的边缘情况——*单态限定*

当模块顶层的变量定义（不在lambda中的表达式）是多态定义，单态限定意味着：如果这些变量值的类型是``Num``的实例类型，则这些值会被强制使用单态类型填充，
这个类型由``default``指定的类型依次尝试，默认情况下，先是`Integer`，再是`Double`。

~~~~ {.haskell include="src/04-extensions/monomorphism.hs"}
~~~~

从GHC 7.8起，GHCi默认关闭单态限定。

```haskell
λ: set +t

λ: 3
3
it :: Num a => a

λ: default (Double)

λ: 3
3.0
it :: Num a => a
```

Safe Haskell
------------

大家最终会发现，在GHC实现（而不是Haskell语言）当中，有些函数会艹翻Haskell的类型系统，这些函数以``unsafe``作为前缀。
这些函数只有在你能确信代码是可靠的，并且类型系统无法表达时才应该使用。如果在不能证实代码安全可靠的情况下擅自使用，我送你四个大字：回家等死吧。
如果你刚开始用Haskell做一些东西，相信我，别用。

```haskell
unsafeCoerce :: a -> b
unsafePerformIO :: IO a -> a
```

Safe Haskell相关的扩展可以禁用不安全的语言特性。通过``-XSafe``扩展，你只能导入被标记为"Safe"的模块。它还禁止使用某些语言扩展（``-XTemplateHaskell``），
因为它可以生成不安全的代码。这些扩展的主要用于安全审计。

```haskell
{-# LANGUAGE Safe #-}
{-# LANGUAGE Trustworthy #-}
```

~~~~ {.haskell include="src/04-extensions/safe.hs"}
~~~~

```haskell
Unsafe.Coerce: Can't be safely imported!
The module itself isn't safe.
```

参见: [Safe Haskell](https://ghc.haskell.org/trac/ghc/wiki/SafeHaskell)

模式守卫
--------------

```haskell
{-# LANGUAGE PatternGuards #-}

combine env x y
   | Just a <- lookup x env
   , Just b <- lookup y env
   = Just $ a + b

   | otherwise = Nothing
```

视图模式
-------------

~~~~ {.haskell include="src/04-extensions/views.hs"}
~~~~

其他语法扩展
----------------------

**元组截面**

```haskell
{-# LANGUAGE TupleSections #-}

first :: a -> (a, Bool)
first = (,True)

second :: a -> (Bool, a)
second = (True,)
```

**多路if表达式**

```haskell
{-# LANGUAGE MultiWayIf #-}

operation x =
  if | x > 100   = 3
     | x > 10    = 2
     | x > 1     = 1
     | otherwise = 0
```

**Lambda Case**

~~~~ {.haskell include="src/04-extensions/lambdacase.hs"}
~~~~

**带包名导入**

```haskell
import qualified "mtl" Control.Monad.Error as Error
import qualified "mtl" Control.Monad.State as State
import qualified "mtl" Control.Monad.Reader as Reader
```

**记录通配符**

记录通配符可以隐式地将字段名用作变量。

~~~~ {.haskell include="src/04-extensions/wildcards.hs"}
~~~~

Pattern Synonyms
----------------

Suppose we were writing a typechecker, it would be very common to include a
distinct ``TArr`` term to ease the telescoping of function signatures, this is what
GHC does in its Core language. Even though technically it could be written in
terms of more basic application of the ``(->)`` constructor.

```haskell
data Type
  = TVar TVar
  | TCon TyCon
  | TApp Type Type
  | TArr Type Type
  deriving (Show, Eq, Ord)
```

With pattern synonyms we can eliminate the extraneous constructor without
losing the convenience of pattern matching on arrow types.

```haskell
{-# LANGUAGE PatternSynonyms #-}

pattern TArr t1 t2 = TApp (TApp (TCon "(->)") t1) t2
```

So now we can write an eliminator and constructor for arrow type very naturally.

~~~~ {.haskell include="src/04-extensions/patterns.hs"}
~~~~

惰性
========

又是一个重墨铺陈的主题。Haskell界现在
Again, a subject on which *much* ink has been spilled. There is an ongoing
discussion in the land of Haskell about the compromises between lazy and strict
evaluation, and there are nuanced arguments for having either paradigm be the
default. Haskell takes a hybrid approach and allows strict evaluation when
needed and uses laziness by default. Needless to say, we can always find
examples where strict evaluation exhibits worse behavior than lazy evaluation
and vice versa.

The primary advantage of lazy evaluation in the large is that algorithms that
operate over both unbounded and bounded data structures can inhabit the same
type signatures and be composed without additional need to restructure their
logic or force intermediate computations. Languages that attempt to bolt
laziness on to a strict evaluation model often bifurcate classes of algorithms
into ones that are hand-adjusted to consume unbounded structures and those which
operate over bounded structures. In strict languages mixing and matching between
lazy vs strict processing often necessitates manifesting large intermediate
structures in memory when such composition would "just work" in a lazy language.

By virtue of Haskell being the only language to actually explore this point in
the design space to the point of being industrial strength; knowledge about lazy
evaluation is not widely absorbed into the collective programmer consciousness
and can often be non-intuitive to the novice. This does reflect on the model
itself, merely on the need for more instruction material and research on
optimizing lazy compilers.

The paradox of Haskell is that it explores so many definably unique ideas (
laziness, purity, typeclasses ) that it becomes difficult to separate out the
discussion of any one from the gestalt of the whole implementation.

See:

* [Oh My Laziness!](http://alpmestan.com/posts/2013-10-02-oh-my-laziness.html)
* [Reasoning about Laziness](http://www.slideshare.net/tibbe/reasoning-about-laziness)
* [Lazy Evaluation of Haskell](http://www.vex.net/~trebla/haskell/lazy.xhtml)
* [More Points For Lazy Evaluation](http://augustss.blogspot.hu/2011/05/more-points-for-lazy-evaluation-in.html)
* [How Lazy Evaluation Works in Haskell](https://hackhands.com/lazy-evaluation-works-haskell/)

Strictness
----------

There are several evaluation models for the lambda calculus:

* Strict - Evaluation is said to be strict if all arguments are evaluated before
  the body of a function.
* Non-strict - Evaluation is non-strict if the arguments are not necessarily
  evaluated before entering the body of a function.

These ideas give rise to several models, Haskell itself use the *call-by-need*
model.

Model          Strictness    Description
-------------  ------------- ---------------
Call-by-value  Strict        arguments evaluated before function entered
Call-by-name   Non-strict    arguments passed unevaluated
Call-by-need   Non-strict    arguments passed unevaluated but an expression is only evaluated once (sharing)

Seq和弱首范式
------------

一个表达式，如果它的最外层构造子或lambda表达式不能继续归约，则称为*弱首范式*。一个表达式，如果已经完全求值，其包含的子表达式和次程式
都完成求值，则称它为*范式*。

```haskell
-- 范式
42
(2, "foo")
\x -> x + 1

-- 非范式
1 + 2
(\x -> x + 1) 2
"foo" ++ "bar"
(1 + 1, "foo")

-- 弱首范式
(1 + 1, "foo")
\x -> 2 + 2
'f' : ("oo" ++ "bar")

-- 非弱首范式
1 + 1
(\x -> x + 1) 2
"foo" ++ "bar"
```

In Haskell normal evaluation only occurs at the outer constructor of case-statements
in Core. If we pattern match on a list we don't implicitly force all values in
the list. An element in a data structure is only evaluated up to the most outer
constructor. For example, to evaluate the length of a list we need only
scrutinize the outer Cons constructors without regard for their inner values.

```haskell
λ: length [undefined, 1]
2

λ: head [undefined, 1]
Prelude.undefined

λ: snd (undefined, 1)
1

λ: fst (undefined, 1)
Prelude.undefined
```

For example, in a lazy language the following program terminates even though it
contains diverging terms.

~~~~ {.haskell include="src/05-laziness/nodiverge.hs"}
~~~~

In a strict language like OCaml ( ignoring its suspensions for the moment ),
the same program diverges.

~~~~ {.haskell include="src/05-laziness/diverge.ml"}
~~~~

In Haskell a *thunk* is created to stand for an unevaluated computation.
Evaluation of a thunk is called *forcing* the thunk. The result is an *update*,
a referentially transparent effect, which replaces the memory representation of
the thunk with the computed value. The fundamental idea is that a thunk is only
updated once ( although it may be forced simultaneously in a multi-threaded
environment ) and its resulting value is shared when referenced subsequently.

The command ``:sprint`` can be used to introspect the state of unevaluated
thunks inside an expression without forcing evaluation. For instance:

```haskell
λ: let a = [1..] :: [Integer]
λ: let b = map (+ 1) a

λ: :sprint a
a = _
λ: :sprint b
b = _
λ: a !! 4
5
λ: :sprint a
a = 1 : 2 : 3 : 4 : 5 : _
λ: b !! 10
12
λ: :sprint a
a = 1 : 2 : 3 : 4 : 5 : 6 : 7 : 8 : 9 : 10 : 11 : _
λ: :sprint b
b = _ : _ : _ : _ : _ : _ : _ : _ : _ : _ : 12 : _
```

While a thunk is being computed its memory representation is replaced with a
special form known as *blackhole* which indicates that computation is ongoing
and allows for a short circuit for when a computation might depend on itself to
complete. The implementation of this is some of the more subtle details of the
GHC runtime.

The ``seq`` function introduces an artificial dependence on the evaluation of
order of two terms by requiring that the first argument be evaluated to WHNF
before the evaluation of the second. The implementation of the `seq` function is
an implementation detail of GHC.

```haskell
seq :: a -> b -> b

⊥ `seq` a = ⊥
a `seq` b = b
```

The infamous ``foldl`` is well-known to leak space when used carelessly and
without several compiler optimizations applied. The strict ``foldl'`` variant
uses seq to overcome this.

```haskell
foldl :: (a -> b -> a) -> a -> [b] -> a
foldl f z [] = z
foldl f z (x:xs) = foldl f (f z x) xs
```

```haskell
foldl' :: (a -> b -> a) -> a -> [b] -> a
foldl' _ z [] = z
foldl' f z (x:xs) = let z' = f z x in z' `seq` foldl' f z' xs
```

In practice, a combination between the strictness analyzer and the inliner on
``-O2`` will ensure that the strict variant of ``foldl`` is used whenever the
function is inlinable at call site so manually using ``foldl'`` is most often
not required.

Of important note is that GHCi runs without any optimizations applied so the
same program that performs poorly in GHCi may not have the same performance
characteristics when compiled with GHC.

Strictness Annotations
----------------------

The extension ``BangPatterns`` allows an alternative syntax to force arguments
to functions to be wrapped in seq. A bang operator on an arguments forces its
evaluation to weak head normal form before performing the pattern match. This
can be used to keep specific arguments evaluated throughout recursion instead of
creating a giant chain of thunks.

```haskell
{-# LANGUAGE BangPatterns #-}

sum :: Num a => [a] -> a
sum = go 0
  where
    go !acc (x:xs) = go (acc + x) (go xs)
    go  acc []     = acc
```

This is desugared into code effectively equivalent to the following:

```haskell
sum :: Num a => [a] -> a
sum = go 0
  where
    go acc _ | acc `seq` False = undefined
    go acc (x:xs)              = go (acc + x) (go xs)
    go acc []                  = acc
```

Function application to seq'd arguments is common enough that it has a special
operator.

```haskell
($!) :: (a -> b) -> a -> b
f $! x  = let !vx = x in f vx
```

Deepseq
-------

There are often times when for performance reasons we need to deeply evaluate a
data structure to normal form leaving no terms unevaluated. The ``deepseq``
library performs this task.

The typeclass ``NFData`` (Normal Form Data) allows us to seq all elements of a
structure across any subtypes which themselves implement NFData.

```haskell
class NFData a where
  rnf :: a -> ()
  rnf a = a `seq` ()

deepseq :: NFData a => a -> b -> a
($!!) :: (NFData a) => (a -> b) -> a -> b
```

```haskell
instance NFData Int
instance NFData (a -> b)

instance NFData a => NFData (Maybe a) where
    rnf Nothing  = ()
    rnf (Just x) = rnf x

instance NFData a => NFData [a] where
    rnf [] = ()
    rnf (x:xs) = rnf x `seq` rnf xs
```

```haskell
[1, undefined] `seq` ()
-- ()

[1, undefined] `deepseq` ()
-- Prelude.undefined
```

To force a data structure itself to be fully evaluated we share the same
argument in both positions of deepseq.

```haskell
force :: NFData a => a
force x = x `deepseq` x
```

Irrefutable Patterns
--------------------

A lazy pattern doesn't require a match on the outer constructor, instead it
lazily calls the accessors of the values failing at each call-site instead at
the outer pattern match in the presence of a bottom.

~~~~ {.haskell include="src/05-laziness/lazy_patterns.hs"}
~~~~

Moral Correctness
-----------------

The caveat with lazy evaluation is that it implies inductive reasoning about
functions, because we must always take into account the fact that a function may contain
bottoms. And as such claims about inductive proofs of functions have to be couched
in an implied set of qualifiers "up to the fast and loose reasoning" assuming
the non-existence of bottoms.

In the "Fast and Loose Reasoning is Morally Correct" paper John Hughes et al.
showed that if two terms have the same semantics in the total language, then
they have related semantics in the partial language and gave a prescription by
which we can translate our knowledge between the two domains given a specific
set of finely stated conditions under which proofs about lazy languages are
indeed rigorous and sound.

* [Fast and Loose Reasoning is Morally Correct](http://www.cse.chalmers.se/~nad/publications/danielsson-et-al-popl2006.html)

Prelude
=======

What to Avoid?
--------------

Haskell being a 25 year old language has witnessed several revolutions in the way we structure and compose
functional programs. Yet as a result several portions of the Prelude still reflect old schools of thought that
simply can't be removed without breaking significant parts of the ecosystem.

Currently it really only exists in folklore which parts to use and which not to use, although this is a topic
that almost all introductory books don't mention and instead make extensive use of the Prelude for simplicity's
sake.

The short version of the advice on the Prelude is:

* Use ``fmap`` instead of ``map``.
* Use Foldable and Traversable instead of the Control.Monad, and Data.List versions of traversals.
* Avoid partial functions like ``head`` and ``read`` or use their total variants.
* Avoid asynchronous exceptions.
* Avoid boolean blind functions.

The instances of Foldable for the list type often conflict with the monomorphic versions in the Prelude which
are left in for historical reasons. So often times it is desirable to explicitly mask these functions from
implicit import and force the use of Foldable and Traversable instead:

```haskell
import  Data.List hiding (
    all , and , any , concat , concatMap find , foldl ,
    foldl' , foldl1 , foldr , foldr1 , mapAccumL ,
    mapAccumR , maximum , maximumBy , minimum ,
    minimumBy , notElem , or , product , sum )

import Control.Monad hiding (
    forM , forM_ , mapM , mapM_ , msum , sequence , sequence_ )
```

Of course often times one wishes only to use the Prelude explicitly and one can
explicitly import it qualified and use the pieces as desired without the
implicit import of the whole namespace.

```haskell
import qualified Prelude as P
```

This does however bring in several typeclass instances and classes regardless of
whether it is explicitly or implicitly imported. If one really desires to use
nothing from the Prelude then the option exists to exclude the entire prelude (
except for the wired-in class instances ) with the ``-XNoImplicitPrelude``
pragma.

```haskell
{-# LANGUAGE NoImplicitPrelude #-}
```

The Prelude itself is entirely replicable as well presuming that an entire
project is compiled without the implicit Prelude. Several packages have arisen
that supply much of the same functionality in a way that appeals to more modern
design principles.

* [base-prelude](http://hackage.haskell.org/package/base-prelude)
* [basic-prelude](http://hackage.haskell.org/package/basic-prelude)
* [classy-prelude](http://hackage.haskell.org/package/classy-prelude)

Partial Functions
-----------------

A *partial function* is a function which doesn't terminate and yield a value for all given inputs. Conversely a
*total function* terminates and is always defined for all inputs. As mentioned previously, certain historical
parts of the Prelude are full of partial functions.

The difference between partial and total functions is the compiler can't reason about the runtime safety of
partial functions purely from the information specified in the language and as such the proof of safety is
left to the user to guarantee. They are safe to use in the case where the user can guarantee that invalid
inputs cannot occur, but like any unchecked property its safety or not-safety is going to depend on the
diligence of the programmer. This very much goes against the overall philosophy of Haskell and as such they
are discouraged when not necessary.

```haskell
head :: [a] -> a
read :: Read a => String -> a
(!!) :: [a] -> Int -> a
```

Safe
----

The Prelude has total variants of the historical partial functions (i.e. ``Text.Read.readMaybe``)in some
cases, but often these are found in the various utility libraries like ``safe``.

The total versions provided fall into three cases:

* ``May``  - return Nothing when the function is not defined for the inputs
* ``Def``  - provide a default value when the function is not defined for the inputs
* ``Note`` - call ``error`` with a custom error message when the function is not defined for the inputs. This
  is not safe, but slightly easier to debug!

```haskell
-- Total
headMay :: [a] -> Maybe a
readMay :: Read a => String -> Maybe a
atMay :: [a] -> Int -> Maybe a

-- Total
headDef :: a -> [a] -> a
readDef :: Read a => a -> String -> a
atDef   :: a -> [a] -> Int -> a

-- Partial
headNote :: String -> [a] -> a
readNote :: Read a => String -> String -> a
atNote   :: String -> [a] -> Int -> a
```

Boolean Blindness
------------------

```haskell
data Bool = True | False

isJust :: Maybe a -> Bool
isJust (Just x) = True
isJust Nothing  = False
```

The problem with the boolean type is that there is effectively no difference
between True and False at the type level. A proposition taking a value to a Bool
takes any information given and destroys it. To reason about the behavior we
have to trace the provenance of the proposition we're getting the boolean answer
from, and this introduces a whole slew of possibilities for misinterpretation. In
the worst case, the only way to reason about safe and unsafe use of a function
is by trusting that a predicate's lexical name reflects its provenance!

For instance, testing some proposition over a Bool value representing whether
the branch can perform the computation safely in the presence of a null is
subject to accidental interchange. Consider that in a language like C or Python
testing whether a value is null is indistinguishable to the language from
testing whether the value is *not null*. Which of these programs encodes safe
usage and which segfaults?

```python
# This one?
if p(x):
    # use x
elif not p(x):
    # don't use x

# Or this one?
if p(x):
    # don't use x
elif not p(x):
    # use x
```

For inspection we can't tell without knowing how p is defined, the compiler
can't distinguish the two either and thus the language won't save us if we
happen to mix them up. Instead of making invalid states *unrepresentable* we've
made the invalid state *indistinguishable* from the valid one!

The more desirable practice is to match on terms which explicitly witness
the proposition as a type ( often in a sum type ) and won't typecheck otherwise.

```haskell
case x of
  Just a  -> use x
  Nothing -> don't use x

-- not ideal
case p x of
  True  -> use x
  False -> don't use x

-- not ideal
if p x
  then use x
  else don't use x
```

To be fair though, many popular languages completely lack the notion of sum types ( the source of many woes in
my opinion ) and only have product types, so this type of reasoning sometimes has no direct equivalence for
those not familiar with ML family languages.

In Haskell, the Prelude provides functions like ``isJust`` and ``fromJust`` both of which can be used to
subvert this kind of reasoning and make it easy to introduce bugs and should often be avoided.

Foldable / Traversable
----------------------

If coming from an imperative background retraining one's self to think about iteration over lists in terms of
maps, folds, and scans can be challenging.

```haskell
Prelude.foldl :: (a -> b -> a) -> a -> [b] -> a
Prelude.foldr :: (a -> b -> b) -> b -> [a] -> b

-- pseudocode
foldr f z [a...] = f a (f b ( ... (f y z) ... ))
foldl f z [a...] = f ... (f (f z a) b) ... y
```

For a concrete consider the simple arithmetic sequence over the binary operator
``(+)``:

```haskell
-- foldr (+) 1 [2..]
(1 + (2 + (3 + (4 + ...))))
```

```haskell
-- foldl (+) 1 [2..]
((((1 + 2) + 3) + 4) + ...)
```

Foldable and Traversable are the general interface for all traversals and folds
of any data structure which is parameterized over its element type ( List, Map,
Set, Maybe, ...). These two classes are used everywhere in modern Haskell
and are extremely important.

A foldable instance allows us to apply functions to data types of monoidal
values that collapse the structure using some logic over ``mappend``.

A traversable instance allows us to apply functions to data types that walk the
structure left-to-right within an applicative context.

```haskell
class (Functor f, Foldable f) => Traversable f where
  traverse :: Applicative g => f (g a) -> g (f a)

class Foldable f where
  foldMap :: Monoid m => (a -> m) -> f a -> m
```

The ``foldMap`` function is extremely general and non-intuitively many of the
monomorphic list folds can themselves be written in terms of this single
polymorphic function.

``foldMap`` takes a function of values to a monoidal quantity, a functor over
the values and collapses the functor into the monoid. For instance for the
trivial Sum monoid:

```haskell
λ: foldMap Sum [1..10]
Sum {getSum = 55}
```

The full Foldable class (with all default implementations) contains a variety of
derived functions which themselves can be written in terms of ``foldMap`` and
``Endo``.

```haskell
newtype Endo a = Endo {appEndo :: a -> a}

instance Monoid (Endo a) where
        mempty = Endo id
        Endo f `mappend` Endo g = Endo (f . g)
```

```haskell
class Foldable t where
    fold    :: Monoid m => t m -> m
    foldMap :: Monoid m => (a -> m) -> t a -> m

    foldr   :: (a -> b -> b) -> b -> t a -> b
    foldr'  :: (a -> b -> b) -> b -> t a -> b

    foldl   :: (b -> a -> b) -> b -> t a -> b
    foldl'  :: (b -> a -> b) -> b -> t a -> b

    foldr1  :: (a -> a -> a) -> t a -> a
    foldl1  :: (a -> a -> a) -> t a -> a
```

For example:

```haskell
foldr :: (a -> b -> b) -> b -> t a -> b
foldr f z t = appEndo (foldMap (Endo . f) t) z
```

Most of the operations over lists can be generalized in terms of combinations of
Foldable and Traversable to derive more general functions that work over all
data structures implementing Foldable.

```haskell
Data.Foldable.elem    :: (Eq a, Foldable t) => a -> t a -> Bool
Data.Foldable.sum     :: (Num a, Foldable t) => t a -> a
Data.Foldable.minimum :: (Ord a, Foldable t) => t a -> a
Data.Traversable.mapM :: (Monad m, Traversable t) => (a -> m b) -> t a -> m (t b)
```

Unfortunately for historical reasons the names exported by foldable quite often conflict with ones defined in
the Prelude, either import them qualified or just disable the Prelude. The operations in the Foldable all
specialize to the same and behave the same as the ones in Prelude for List types.

~~~~ {.haskell include="src/06-prelude/foldable_traversable.hs"}
~~~~

The instances we defined above can also be automatically derived by GHC using several language extensions. The
automatic instances are identical to the hand-written versions above.

```haskell
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE DeriveTraversable #-}

data Tree a = Node a [Tree a]
  deriving (Show, Functor, Foldable, Traversable)
```

See: [Typeclassopedia](http://wiki.haskell.org/Typeclassopedia)

Corecursion
-----------

```haskell
unfoldr :: (b -> Maybe (a, b)) -> b -> [a]
```

A recursive function consumes data and eventually terminates, a corecursive
function generates data and **coterminates**. A corecursive function is said to be
*productive* if it can always evaluate more of the resulting value in bounded time.

```haskell
import Data.List

f :: Int -> Maybe (Int, Int)
f 0 = Nothing
f x = Just (x, x-1)

rev :: [Int]
rev = unfoldr f 10

fibs :: [Int]
fibs = unfoldr (\(a,b) -> Just (a,(b,a+b))) (0,1)
```

Split
-----

The [split](http://hackage.haskell.org/package/split-0.1.1/docs/Data-List-Split.html) package provides a
variety of missing functions for splitting list and string types.

~~~~ {.haskell include="src/06-prelude/split.hs"}
~~~~

Monad-loops
-----------

The [monad-loops](http://hackage.haskell.org/package/monad-loops-0.4.2/docs/Control-Monad-Loops.html) package
provides a variety of missing functions for control logic in monadic contexts.

```haskell
whileM :: Monad m => m Bool -> m a -> m [a]
untilM :: Monad m => m a -> m Bool -> m [a]
iterateUntilM :: Monad m => (a -> Bool) -> (a -> m a) -> a -> m a
whileJust :: Monad m => m (Maybe a) -> (a -> m b) -> m [b]
```

Text / ByteString
=================

The default Haskell string type is the rather naive linked list of characters, that while perfectly fine for
small identifiers is not well-suited for bulk processing.

```haskell
type String = [Char]
```

For more performance sensitive cases there are two libraries for processing textual data: ``text`` and
``bytestring``.  With the ``-XOverloadedStrings`` extension string literals can be overloaded without the need
for explicit packing and can be written as string literals in the Haskell source and overloaded via a
typeclass ``IsString``.

```haskell
class IsString a where
  fromString :: String -> a
```

For instance:

```haskell
λ: :type "foo"
"foo" :: [Char]

λ: :set -XOverloadedStrings

λ: :type "foo"
"foo" :: IsString a => a
```

Text
----

A ``Text`` type is a packed blob of Unicode characters.

```haskell
pack :: String -> Text
unpack :: Text -> String
```

~~~~ {.haskell include="src/07-text-bytestring/text.hs"}
~~~~

See: [Text](http://hackage.haskell.org/package/text-1.1.0.1/docs/Data-Text.html)

Text.Builder
------------

```haskell
toLazyText :: Builder -> Data.Text.Lazy.Internal.Text
fromLazyText :: Data.Text.Lazy.Internal.Text -> Builder
```

The Text.Builder allows the efficient monoidal construction of lazy Text types
without having to go through inefficient forms like String or List types as
intermediates.

~~~~ {.haskell include="src/07-text-bytestring/builder.hs"}
~~~~

ByteString
----------

ByteStrings are arrays of unboxed characters with either strict or lazy evaluation.

```haskell
pack :: String -> ByteString
unpack :: ByteString -> String
```

~~~~ {.haskell include="src/07-text-bytestring/bytestring.hs"}
~~~~

See:

* [Bytestring: Bits and Pieces](https://www.fpcomplete.com/school/to-infinity-and-beyond/pick-of-the-week/bytestring-bits-and-pieces)
* [ByteString](http://hackage.haskell.org/package/bytestring-0.10.4.0/docs/Data-ByteString.html)

Printf
------

Haskell also has a variadic ``printf`` function in the style of C.

~~~~ {.haskell include="src/07-text-bytestring/printf.hs"}
~~~~

Overloaded Lists
----------------

It is ubiquitous for data structure libraries to expose ``toList`` and ``fromList`` functions to construct
various structures out of lists. As of GHC 7.8 we now have the ability to overload the list syntax in the
surface language with a typeclass ``IsList``.

```haskell
class IsList l where
  type Item l
  fromList  :: [Item l] -> l
  toList    :: l -> [Item l]

instance IsList [a] where
  type Item [a] = a
  fromList = id
  toList   = id
```

```haskell
λ: :type [1,2,3]
[1,2,3] :: (Num (Item l), IsList l) => l
```

~~~~ {.haskell include="src/07-text-bytestring/overloadedlist.hs"}
~~~~

应用式函子
============

和单子一样，应用式函子也是一种表达计算方式的抽象结构，从通用性来讲介乎函子和单子之间。

```haskell
pure :: Applicative f => a -> f a
(<$>) :: Functor f => (a -> b) -> f a -> f b
(<*>) :: f (a -> b) -> f a -> f b
```

从GHC 7.6开始，应用式函数的定义变为如下形式：

```haskell
class Functor f => Applicative f where
  pure :: a -> f a
  (<*>) :: f (a -> b) -> f a -> f b

(<$>) :: Functor f => (a -> b) -> f a -> f b
(<$>) = fmap
```

应用式函子定律如下：

```haskell
pure id <*> v = v
pure f <*> pure x = pure (f x)
u <*> pure y = pure ($ y) <*> u
u <*> (v <*> w) = pure (.) <*> u <*> v <*> w
```

我们以Maybe举例：

```haskell
instance Applicative Maybe where
  pure              = Just
  Nothing <*> _     = Nothing
  _ <*> Nothing     = Nothing
  Just f <*> Just x = Just (f x)
```

如果你想写``m >>= return . f``这样的代码，那么很可能应用式单子更适合。这是一个比较通用的准则。

~~~~ {.haskell include="src/08-applicatives/applicative.hs"}
~~~~

我们经常会看到形似``f <$> a <*> b ...``这样的代码，于是有一类函数专门用来将应用式函子提升为接收
固定个数参数的形式。单子中也有类似的一类函数（``liftM``、``liftM2``、``liftM3``）

```haskell
liftA :: Applicative f => (a -> b) -> f a -> f b
liftA f a = pure f <*> a

liftA2 :: Applicative f => (a -> b -> c) -> f a -> f b -> f c
liftA2 f a b = f <$> a <*> b

liftA3 :: Applicative f => (a -> b -> c -> d) -> f a -> f b -> f c -> f d
liftA3 f a b c = f <$> a <*> b <*> c
```

此外，还有两个函数``*>``和``<*``，用于顺序执行应用式函子，同时舍弃其中一个结果。``*>``舍弃左边
的结果，而``<*``舍弃右边的结果。例如在某些单子化的解析器组合子类库中，``*>``使用左右两边的解析器
进行解析，但是只保留右边的解析结果（译者注：原文（For example in a monadic
parser combinator library the ``*>`` would parse with first parser argument but
return the second.）表达不是很明确）。

应用式函子中的函数``<$>``和``<*>``是由单子函数``liftM``和``ap``演变而来。

```haskell
import Control.Monad
import Control.Applicative

data C a b = C a b

mnd :: Monad m => m a -> m b -> m (C a b)
mnd a b = C `liftM` a `ap` b

apl :: Applicative f => f a -> f b -> f (C a b)
apl a b = C <$> a <*> b
```

参见: [Applicative Programming with Effects](http://www.soi.city.ac.uk/~ross/papers/Applicative.pdf)

类型类之间的继承关系
-------------------

原则上，所有的单子必须同时是一个应用式函子（那么显然也必须是一个函子）。但是由于历史原因，Applicative不是Monad类型类的超类。
（译者注：从GHC 7.10起，Applicative已经成为Monad的超类，参见：[](https://wiki.haskell.org/Functor-Applicative-Monad_Proposal)）
设想中，Prelude中应该有下面的定义：

```haskell
class Functor f where
  fmap :: (a -> b) -> f a -> f b

class Functor f => Applicative f where
  pure :: a -> f a
  (<*>) :: f (a -> b) -> f a -> f b

class Applicative m => Monad m where
  (>>=) :: m a -> (a -> m b) -> m b
  ma >>= f = join (fmap f ma)

return :: Applicative m => a -> m a
return = pure

join :: Monad m => m (m a) -> m a
join x = x >>= id
```

参见: [Functor-Applicative-Monad Proposal](http://wiki.haskell.org/Functor-Applicative-Monad_Proposal)

Alternative
-----------

Alternative is an extension of the Applicative class with a zero element and an associative binary operation
respecting the zero.

```haskell
class Applicative f => Alternative f where
  -- | The identity of '<|>'
  empty :: f a
  -- | An associative binary operation
  (<|>) :: f a -> f a -> f a
  -- | One or more.
  some :: f a -> f [a]
  -- | Zero or more.
  many :: f a -> f [a]

optional :: Alternative f => f a -> f (Maybe a)
```

```haskell
instance Alternative Maybe where
    empty = Nothing
    Nothing <|> r = r
    l       <|> _ = l

instance Alternative [] where
    empty = []
    (<|>) = (++)
```

```haskell
λ: foldl1 (<|>) [Nothing, Just 5, Just 3]
Just 5
```

These instances show up very frequently in parsers where the alternative operator can model alternative parse
branches.

可变参数个数的函数
----------------------

类型类有一个令人称奇的用处，用它可以构造接收任意数量参数的函数。参数可以是任意类型，但是最后收集到的参数必须转换成同一类型或者用聚合的办法组装起来。

~~~~ {.haskell include="src/08-applicatives/variadic.hs"}
~~~~

参见: [Polyvariadic functions](http://okmij.org/ftp/Haskell/polyvariadic.html)


Category
--------

A category is an algebraic structure that includes a notion of an identity and a
composition operation that is associative and preserves identities.

```haskell
class Category cat where
  id :: cat a a
  (.) :: cat b c -> cat a b -> cat a c
```

```haskell
instance Category (->) where
  id = Prelude.id
  (.) = (Prelude..)
```

```haskell
(<<<) :: Category cat => cat b c -> cat a b -> cat a c
(<<<) = (.)

(>>>) :: Category cat => cat a b -> cat b c -> cat a c
f >>> g = g . f
```

Arrows
------

Arrows are an extension of categories with the notion of products.

```haskell
class Category a => Arrow a where
  arr :: (b -> c) -> a b c
  first :: a b c -> a (b,d) (c,d)
  second :: a b c -> a (d,b) (d,c)
  (***) :: a b c -> a b' c' -> a (b,b') (c,c')
  (&&&) :: a b c -> a b c' -> a b (c,c')
```

The canonical example is for functions.

```haskell
instance Arrow (->) where
  arr f = f
  first f = f *** id
  second f = id *** f
  (***) f g ~(x,y) = (f x, g y)
```

In this form functions of multiple arguments can be threaded around using the
arrow combinators in a much more pointfree form. For instance a histogram
function has a nice one-liner.

```haskell
import Data.List (group, sort)

histogram :: Ord a => [a] -> [(a, Int)]
histogram = map (head &&& length) . group . sort
```

```haskell
λ: histogram "Hello world"
[(' ',1),('H',1),('d',1),('e',1),('l',3),('o',2),('r',1),('w',1)]
```

**Arrow notation**

The following are equivalent:

```haskell
{-# LANGUAGE Arrows #-}

addA :: Arrow a => a b Int -> a b Int -> a b Int
addA f g = proc x -> do
                y <- f -< x
                z <- g -< x
                returnA -< y + z
```

```haskell
addA f g = arr (\ x -> (x, x)) >>>
           first f >>> arr (\ (y, x) -> (x, y)) >>>
           first g >>> arr (\ (z, y) -> y + z)
```

```haskell
addA f g = f &&& g >>> arr (\ (y, z) -> y + z)
```

In practice this notation is not used often and in the future may become deprecated.

See: [Arrow Notation](https://downloads.haskell.org/~ghc/7.8.3/docs/html/users_guide/arrow-notation.html)

Bifunctors
----------

Bifunctors are a generalization of functors to include types parameterized by
two parameters and include two map functions for each parameter.

```haskell
class Bifunctor p where
  bimap :: (a -> b) -> (c -> d) -> p a c -> p b d
  first :: (a -> b) -> p a c -> p b c
  second :: (b -> c) -> p a b -> p a c
```

The bifunctor laws are a natural generalization of the usual functor. Namely
they respect identities and composition in the usual way:

```haskell
bimap id id ≡ id
first id ≡ id
second id ≡ id
```

```haskell
bimap f g ≡ first f . second g
```

The canonical example is for 2-tuples.

```haskell
λ: first (+1) (1,2)
(2,2)
λ: second (+1) (1,2)
(1,3)
λ: bimap (+1) (+1) (1,2)
(2,3)

λ: first (+1) (Left 3)
Left 4
λ: second (+1) (Left 3)
Left 3
λ: second (+1) (Right 3)
Right 4
```

Error Handling
==============

Control.Exception
-----------------

The low-level (and most dangerous) way to handle errors is to use the ``throw`` and ``catch`` functions which
allow us to throw extensible exceptions in pure code but catch the resulting exception within IO.  Of
specific note is that return value of the ``throw`` inhabits all types. There's no reason to use this for
custom code that doesn't use low-level system operations.

```haskell
throw :: Exception e => e -> a
catch :: Exception e => IO a -> (e -> IO a) -> IO a
try :: Exception e => IO a -> IO (Either e a)
evaluate :: a -> IO a
```

~~~~ {.haskell include="src/09-errors/ioexception.hs"}
~~~~

Because a value will not be evaluated unless needed, if one desires to know for
sure that an exception is either caught or not it can be deeply forced into head
normal form before invoking catch. The ``strictCatch`` is not provided by
standard library but has a simple implementation in terms of ``deepseq``.

```haskell
strictCatch :: (NFData a, Exception e) => IO a -> (e -> IO a) -> IO a
strictCatch = catch . (toNF =<<)
```

Exceptions
----------

The problem with the previous approach is having to rely on GHC's asynchronous exception handling inside of IO
to handle basic operations. The ``exceptions`` provides the same API as ``Control.Exception`` but loosens the
dependency on IO.

~~~~ {.haskell include="src/09-errors/exceptions.hs"}
~~~~

See: [exceptions](http://hackage.haskell.org/package/exceptions)

Either
------

The instance of the Either monad is simple, note the bias toward Left when
binding.

~~~~ {.haskell include="src/09-errors/either_impl.hs"}
~~~~

The silly example one always sees is writing safe division function that fails
out with a Left value when a division by zero happens and holds the resulting
value in Right otherwise.

~~~~ {.haskell include="src/09-errors/either.hs"}
~~~~

This is admittedly pretty stupid but captures the essence of why Either/EitherT
is a suitable monad for exception handling.

ErrorT
------

In the monad transformer style, we can use the ``ErrorT`` transformer composed
with an Identity monad and unrolling into an ``Either Exception a``. This method
is simple but requires manual instantiation of an Exception ( or Typeable )
typeclass if a custom Exception type is desired.

~~~~ {.haskell include="src/09-errors/errors.hs"}
~~~~

ExceptT
-------

As of mtl 2.2 or higher, the ``ErrorT`` class has been replaced by the ``ExceptT`` which fixes many of the
problems with the old class.

At transformers level.

```haskell
newtype ExceptT e m a = ExceptT (m (Either e a))

runExceptT :: ExceptT e m a -> m (Either e a)
runExceptT (ExceptT m) = m

instance (Monad m) => Monad (ExceptT e m) where
    return a = ExceptT $ return (Right a)
    m >>= k = ExceptT $ do
        a <- runExceptT m
        case a of
            Left e -> return (Left e)
            Right x -> runExceptT (k x)
    fail = ExceptT . fail

throwE :: (Monad m) => e -> ExceptT e m a
throwE = ExceptT . return . Left

catchE :: (Monad m) =>
    ExceptT e m a               -- ^ the inner computation
    -> (e -> ExceptT e' m a)    -- ^ a handler for exceptions in the inner
                                -- computation
    -> ExceptT e' m a
m `catchE` h = ExceptT $ do
    a <- runExceptT m
    case a of
        Left  l -> runExceptT (h l)
        Right r -> return (Right r)
```

At MTL level.

```haskell
instance MonadTrans (ExceptT e) where
    lift = ExceptT . liftM Right

class (Monad m) => MonadError e m | m -> e where
    throwError :: e -> m a
    catchError :: m a -> (e -> m a) -> m a

instance MonadError IOException IO where
    throwError = ioError
    catchError = catch

instance MonadError e (Either e) where
    throwError             = Left
    Left  l `catchError` h = h l
    Right r `catchError` _ = Right r
```

See:

* [Control.Monad.Except](https://hackage.haskell.org/package/mtl-2.2.1/docs/Control-Monad-Except.html)


EitherT
-------

```haskell
newtype EitherT e m a = EitherT {runEitherT :: m (Either e a)}
        -- Defined in `Control.Monad.Trans.Either'
```

```haskell
runEitherT :: EitherT e m a -> m (Either e a)
tryIO :: MonadIO m => IO a -> EitherT IOException m a

throwT  :: Monad m => e -> EitherT e m r
catchT  :: Monad m => EitherT a m r -> (a -> EitherT b m r) -> EitherT b m r
handleT :: Monad m => (a -> EitherT b m r) -> EitherT a m r -> EitherT b m
```

The ideal monad to use is simply the ``EitherT`` monad which we'd like to be able to use with an API
similar to ``ErrorT``. For example suppose we wanted to use ``read`` to attempt to read a positive integer
from stdin. There are two failure modes and two failure cases here, one for a parse error which fails with an
error from ``Prelude.readIO``  and one for a non-positive integer which fails with a custom exception after a
check. We'd like to unify both cases in the same transformer.

Combined, the ``safe`` and ``errors``  make life with ``EitherT`` more pleasant. The safe library provides a
variety of safer variants of the standard prelude functions that handle failures as Maybe values, explicitly
passed default values, or more informative exception "notes".  While the errors library reexports the safe
Maybe functions and hoists them up into the ``EitherT`` monad providing a family of ``try`` prefixed functions
that perform actions and can fail with an exception.

```haskell
-- Exception handling equivalent of `read`
tryRead :: (Monad m, Read a) => e -> String -> EitherT e m a

-- Exception handling equivelent of `head`
tryHead :: Monad m => e -> [a] -> EitherT e m a

-- Exception handling equivelent of `(!!)`
tryAt :: Monad m => e -> [a] -> Int -> EitherT e m a
```

~~~~ {.haskell include="src/09-errors/eithert.hs"}
~~~~

See:

* [Error Handling Simplified](http://www.haskellforall.com/2012/07/errors-10-simplified-error-handling.html)
* [Safe](http://hackage.haskell.org/package/safe)


高端单子
===============

函数单子
--------------

如果你接触Haskell的时候够长，你最终会遇到这个奇葩：``((->) r)``。虽然大家普遍觉得这货用作单子非常别扭，但如果你把它考虑成一个
拆开了的Reader单子，一切就显而易见了。

```haskell
instance Functor ((->) r) where
  fmap = (.)

instance Monad ((->) r) where
  return = const
  f >>= k = \r -> k (f r) r
```

它仅仅使用了“->”类型操作符的前缀形式。

~~~~ {.haskell include="src/10-advanced-monads/function.hs"}
~~~~

```haskell
type Reader r = (->) r -- 伪代码

instance Monad (Reader r) where
  return a = \_ -> a
  f >>= k = \r -> k (f r) r

ask' :: r -> r
ask' = id

asks' :: (r -> a) -> (r -> a)
asks' f = id . f

runReader' :: (r -> a) -> r -> a
runReader' = id
```

RWS单子
---------

RWS单子结合了之前说过的**R**eader、**W**riter、**S**tate三种单子的特性。它还有对应的转换器版本，叫作``RWST``。

```haskell
runReader :: Reader r a -> r -> a
runWriter :: Writer w a -> (a, w)
runState  :: State s a -> s -> (a, s)
```

这三个执行函数经过组合成为了下面三个函数：

```haskell
runRWS  :: RWS r w s a -> r -> s -> (a, s, w)
execRWS :: RWS r w s a -> r -> s -> (s, w)
evalRWS :: RWS r w s a -> r -> s -> (a, w)
```

~~~~ {.haskell include="src/10-advanced-monads/rws.hs"}
~~~~

有关Writer惰性特征的注意事项对RWS同样适用。


Cont
----

```haskell
runCont :: Cont r a -> (a -> r) -> r
callCC :: MonadCont m => ((a -> m b) -> m a) -> m a
cont :: ((a -> r) -> r) -> Cont r a
```

In continuation passing style, composite computations are built up from
sequences of nested computations which are terminated by a final continuation
which yields the result of the full computation by passing a function into the
continuation chain.

```haskell
add :: Int -> Int -> Int
add x y = x + y

add :: Int -> Int -> (Int -> r) -> r
add x y k = k (x + y)
```

~~~~ {.haskell include="src/10-advanced-monads/cont.hs"}
~~~~

~~~~ {.haskell include="src/10-advanced-monads/cont_impl.hs"}
~~~~

* [Wikibooks: Continuation Passing Style](http://en.wikibooks.org/wiki/Haskell/Continuation_passing_style)
* [MonadCont Under the Hood](https://wiki.haskell.org/MonadCont_under_the_hood)

MonadPlus
---------

Choice and failure.

```haskell
class Monad m => MonadPlus m where
   mzero :: m a
   mplus :: m a -> m a -> m a

instance MonadPlus [] where
   mzero = []
   mplus = (++)

instance MonadPlus Maybe where
   mzero = Nothing

   Nothing `mplus` ys  = ys
   xs      `mplus` _ys = xs
```

MonadPlus forms a monoid with

```haskell
mzero `mplus` a = a
a `mplus` mzero = a
(a `mplus` b) `mplus` c = a `mplus` (b `mplus` c)
```

```haskell
when :: (Monad m) => Bool -> m () -> m ()
when p s =  if p then s else return ()

guard :: MonadPlus m => Bool -> m ()
guard True  = return ()
guard False = mzero

msum :: MonadPlus m => [m a] -> m a
msum =  foldr mplus mzero
```

~~~~ {.haskell include="src/10-advanced-monads/monadplus.hs"}
~~~~

~~~~ {.haskell include="src/10-advanced-monads/logict.hs"}
~~~~

MonadFix
--------

The fixed point of a monadic computation. ``mfix f`` executes the action ``f`` only once, with the eventual
output fed back as the input.

```haskell
fix :: (a -> a) -> a
fix f = let x = f x in x

mfix :: (a -> m a) -> m a
```

```haskell
class Monad m => MonadFix m where
   mfix :: (a -> m a) -> m a

instance MonadFix Maybe where
   mfix f = let a = f (unJust a) in a
            where unJust (Just x) = x
                  unJust Nothing  = error "mfix Maybe: Nothing"
```

The regular do-notation can also be extended with ``-XRecursiveDo`` to accommodate recursive monadic bindings.

~~~~ {.haskell include="src/10-advanced-monads/monadfix.hs"}
~~~~

ST Monad
--------

The ST monad models "threads" of stateful computations which can manipulate mutable references but are
restricted to only return pure values when evaluated and are statically confined to the ST monad of a ``s``
thread.

```haskell
runST :: (forall s. ST s a) -> a
newSTRef :: a -> ST s (STRef s a)
readSTRef :: STRef s a -> ST s a
writeSTRef :: STRef s a -> a -> ST s ()
```

~~~~ {.haskell include="src/10-advanced-monads/st.hs"}
~~~~

Using the ST monad we can create a class of efficient purely functional data
structures that use mutable references in a referentially transparent way.

Free Monads
-----------

```haskell
Pure :: a -> Free f a
Free :: f (Free f a) -> Free f a

liftF :: (Functor f, MonadFree f m) => f a -> m a
retract :: Monad f => Free f a -> f a
```

Free monads are monads which instead of having a ``join`` operation that combines computations, instead forms
composite computations from application of a functor.

```haskell
join :: Monad m => m (m a) -> m a
wrap :: MonadFree f m => f (m a) -> m a
```

One of the best examples is the Partiality monad which models computations which can diverge. Haskell allows
unbounded recursion, but for example we can create a free monad from the ``Maybe`` functor which can be
used to fix the call-depth of, for example the [Ackermann function](https://en.wikipedia.org/wiki/Ackermann_function).

~~~~ {.haskell include="src/10-advanced-monads/partiality.hs"}
~~~~

The other common use for free monads is to build embedded domain-specific languages to describe computations. We can model
a subset of the IO monad by building up a pure description of the computation inside of the IOFree monad
and then using the free monad to encode the translation to an effectful IO computation.

~~~~ {.haskell include="src/10-advanced-monads/free_dsl.hs"}
~~~~


An implementation such as the one found in [free](http://hackage.haskell.org/package/free) might look like the
following:

~~~~ {.haskell include="src/10-advanced-monads/free_impl.hs"}
~~~~

See:

* [Monads for Free!](http://www.andres-loeh.de/Free.pdf)
* [I/O is not a Monad](http://r6.ca/blog/20110520T220201Z.html)

Indexed Monads
--------------

Indexed monads are a generalisation of monads that adds an additional type parameter to the class that
carries information about the computation or structure of the monadic implementation.

```haskell
class IxMonad md where
  return :: a -> md i i a
  (>>=) :: md i m a -> (a -> md m o b) -> md i o b
```


The canonical use-case is a variant of the vanilla State which allows type-changing on the state for
intermediate steps inside of the monad. This indeed turns out to be very useful for handling a class of problems
involving resource management since the extra index parameter gives us space to statically enforce the
sequence of monadic actions by allowing and restricting certain state transitions on the index parameter at
compile-time.

To make this more usable we'll use the somewhat esoteric ``-XRebindableSyntax`` allowing us to overload the
do-notation and if-then-else syntax by providing alternative definitions local to the module.

~~~~ {.haskell include="src/10-advanced-monads/indexed.hs"}
~~~~

See: [Fun with Indexed monads](http://www.cl.cam.ac.uk/~dao29/ixmonad/ixmonad-fita14.pdf)

Quantification
==============

Universal Quantification
------------------------

Universal quantification the primary mechanism of encoding polymorphism in
Haskell. The essence of universal quantification is that we can express
functions which operate the same way for a set of types and whose function
behavior is entirely determined *only* by the behavior of all types in this
span.

~~~~ {.haskell include="src/11-quantification/universal.hs"}
~~~~

Normally quantifiers are omitted in type signatures since in Haskell's vanilla
surface language it is unambiguous to assume to that free type variables are
universally quantified.

Free theorems
-------------

A universally quantified type-variable actually implies quite a few rather deep
properties about the implementation of a function that can be deduced from its
type signature. For instance the identity function in Haskell is guaranteed to
only have one implementation since the only information that the information
that can present in the body

```haskell
id :: forall a. a -> a
id x = x
```

```haskell
fmap :: Functor f => (a -> b) -> f a -> f b
```

The free theorem of fmap:

```haskell
forall f g. fmap f . fmap g = fmap (f . g)
```

See: [Theorems for Free](http://www-ps.iai.uni-bonn.de/cgi-bin/free-theorems-webui.cgi?)

Type Systems
------------

**Hindley-Milner type system**

The Hindley-Milner type system is historically important as one of the first typed lambda calculi that admitted
both polymorphism and a variety of inference techniques that could always decide principal types.

```haskell
e : x
  | λx:t.e            -- value abstraction
  | e1 e2             -- application
  | let x = e1 in e2  -- let

t : t -> t     -- function types
  | a          -- type variables

σ : ∀ a . t    -- type scheme
```

In an implementation, the function ``generalize`` converts all type variables
within the type into polymorphic type variables yielding a type scheme. The
function ``instantiate`` maps a scheme to a type, but with any polymorphic
variables converted into unbound type variables.

**Rank-N Types**

System-F is the type system that underlies Haskell. System-F subsumes the HM
type system in the sense that every type expressible in HM can be expressed
within System-F. System-F is sometimes referred to in texts as the
*Girald-Reynolds polymorphic lambda calculus* or *second-order lambda calculus*.

```haskell
t : t -> t     -- function types
  | a          -- type variables
  | ∀ a . t    -- forall

e : x          -- variables
  | λ(x:t).e   -- value abstraction
  | e1 e2      -- value application
  | Λa.e       -- type abstraction
  | e_t        -- type application
```

An example with equivalents of GHC Core in comments:

```haskell
id : ∀ t. t -> t
id = Λt. λx:t. x
-- id :: forall t. t -> t
-- id = \ (@ t) (x :: t) -> x

tr : ∀ a. ∀ b. a -> b -> a
tr = Λa. Λb. λx:a. λy:b. x
-- tr :: forall a b. a -> b -> a
-- tr = \ (@ a) (@ b) (x :: a) (y :: b) -> x

fl : ∀ a. ∀ b. a -> b -> b
fl = Λa. Λb. λx:a. λy:b. y
-- fl :: forall a b. a -> b -> b
-- fl = \ (@ a) (@ b) (x :: a) (y :: b) -> y

nil : ∀ a. [a]
nil = Λa. Λb. λz:b. λf:(a -> b -> b). z
-- nil :: forall a. [a]
-- nil = \ (@ a) (@ b) (z :: b) (f :: a -> b -> b) -> z

cons : ∀ a. a -> [a] -> [a]
cons = Λa. λx:a. λxs:(∀ b. b -> (a -> b -> b) -> b).
    Λb. λz:b. λf : (a -> b -> b). f x (xs_b z f)
-- cons :: forall a. a
--       -> (forall b. (a -> b -> b) -> b) -> (forall b. (a -> b -> b) -> b)
-- cons = \ (@ a) (x :: a) (xs :: forall b. (a -> b -> b) -> b)
--     (@ b) (z :: b) (f :: a -> b -> b) -> f x (xs @ b z f)
```

Normally when Haskell's typechecker infers a type signature it places all quantifiers of type variables at the
outermost position such that no quantifiers appear within the body of the type expression, called the
prenex restriction. This restricts an entire class of type signatures that would otherwise be expressible
within System-F, but has the benefit of making inference much easier.

``-XRankNTypes`` loosens the prenex restriction such that we may explicitly place quantifiers within the body
of the type. The bad news is that the general problem of inference in this relaxed system is undecidable in
general, so we're required to explicitly annotate functions which use RankNTypes or they are otherwise
inferred as rank 1 and may not typecheck at all.

~~~~ {.haskell include="src/11-quantification/rankn.hs"}
~~~~

```haskell
Monomorphic Rank 0: t
Polymorphic Rank 1: forall a. a -> t
Polymorphic Rank 2: (forall a. a -> t) -> t
Polymorphic Rank 3: ((forall a. a -> t) -> t) -> t
```

Of important note is that the type variables bound by an explicit quantifier in
a higher ranked type may not escape their enclosing scope, the typechecker will
explicitly enforce this with by enforcing that variables bound inside of rank-n
types ( called skolem constants ) will not unify with free meta type variables
inferred by the inference engine.

~~~~ {.haskell include="src/11-quantification/skolem_capture.hs"}
~~~~

In this example in order for the expression to be well typed, ``f`` would
necessarily have (``Int -> Int``) which implies that ``a ~ Int`` over the whole
type, but since ``a`` is bound under the quantifier it must not be unified with
``Int`` and so the typechecker must fail with a skolem capture error.

```perl
Couldn't match expected type `a' with actual type `t'
`a' is a rigid type variable bound by a type expected by the context: a -> a
`t' is a rigid type variable bound by the inferred type of g :: t -> Int
In the expression: x In the first argument of `escape', namely `(\ a -> x)'
In the expression: escape (\ a -> x)
```

This can actually be used for our advantage to enforce several types of
invariants about scope and use of specific type variables. For example the ST
monad uses a second rank type to prevent the capture of references between ST
monads with separate state threads where the ``s`` type variable is bound within
a rank-2 type and cannot escape, statically guaranteeing that the implementation
details of the ST internals can't leak out and thus ensuring its referential
transparency.

Existential Quantification
--------------------------

The essence of universal quantification is that we can express functions which operate the same way for *any*
type, while for existential quantification we can express functions that operate over an *some* unknown type.
Using an existential we can group heterogeneous values together with functions under the existential, that
manipulate the data types but whose type signature hides this information.

~~~~ {.haskell include="src/11-quantification/existential.hs"}
~~~~

The existential over ``SBox`` gathers a collection of values defined purely in terms of their Show
interface, no other information is available about the values and they can't be accessed or unpacked in any
other way.

~~~~ {.haskell include="src/11-quantification/existential2.hs"}
~~~~

Use of existentials can be used to recreate certain concepts from the so-called "Object Oriented Paradigm", a
school of thought popularized in the late 80s that attempted to decompose programming logic into
anthropomorphic entities and actions instead of the modern equational treatment. Recreating this model in
Haskell is widely considered to be an antipattern.

See: [Haskell Antipattern: Existential Typeclass](http://lukepalmer.wordpress.com/2010/01/24/haskell-antipattern-existential-typeclass/)

Impredicative Types
-------------------

Although extremely brittle, GHC also has limited support for impredicative
polymorphism which allows instantiating type variable with a polymorphic type.
Implied is that this loosens the restriction that quantifiers must
precede arrow types and now they may be placed inside of type-constructors.

```haskell
-- Can't unify ( Int ~ Char )

revUni :: forall a. Maybe ([a] -> [a]) -> Maybe ([Int], [Char])
revUni (Just g) = Just (g [3], g "hello")
revUni Nothing  = Nothing
```

~~~~ {.haskell include="src/11-quantification/impredicative.hs"}
~~~~

Use of this extension is very rare, and there is some consideration that
``-XImpredicativeTypes`` is fundamentally broken. Although GHC is very liberal
about telling us to enable it when one accidentally makes a typo in a type
signature!

Some notable trivia, the ``($)`` operator is wired into GHC in a very special
way as to allow impredicative instantiation of ``runST`` to be applied via
``($)`` by special-casing the ``($)`` operator only when used for the ST monad.
If this sounds like an ugly hack it's because it is, but a rather convenient
hack.

For example if we define a function ``apply`` which should behave identically to
``($)`` we'll get an error about polymorphic instantiation even though they are
defined identically!

```haskell
{-# LANGUAGE RankNTypes #-}

import Control.Monad.ST

f `apply` x =  f x

foo :: (forall s. ST s a) -> a
foo st = runST $ st

bar :: (forall s. ST s a) -> a
bar st = runST `apply` st
```

```haskell
    Couldn't match expected type `forall s. ST s a'
                with actual type `ST s0 a'
    In the second argument of `apply', namely `st'
    In the expression: runST `apply` st
    In an equation for `bar': bar st = runST `apply` st
```

See:

* [SPJ Notes on $](https://www.haskell.org/pipermail/glasgow-haskell-users/2010-November/019431.html)

Scoped Type Variables
---------------------

Normally the type variables used within the toplevel signature for a function
are only scoped to the type-signature and not the body of the function and its
rigid signatures over terms and let/where clauses.  Enabling
``-XScopedTypeVariables`` loosens this restriction allowing the type variables
mentioned in the toplevel to be scoped within the value-level body of a function
and all signatures contained therein.

~~~~ {.haskell include="src/11-quantification/scopedtvars.hs"}
~~~~

GADTs
=====

GADTs
-----

*Generalized Algebraic Data types* (GADTs) are an extension to algebraic
datatypes that allow us to qualify the constructors to datatypes with type
equality constraints, allowing a class of types that are not expressible using
vanilla ADTs.

``-XGADTs`` implicitly enables an alternative syntax for datatype declarations (
``-XGADTSyntax`` )  such that the following declarations are equivalent:

```haskell
-- Vanilla
data List a
  = Empty
  | Cons a (List a)

-- GADTSyntax
data List a where
  Empty :: List a
  Cons :: a -> List a -> List a
```

For an example use consider the data type ``Term``, we have a term in which we
``Succ`` which takes a ``Term`` parameterized by ``a`` which span all types.
Problems arise between the clash whether (``a ~ Bool``) or (``a ~ Int``) when
trying to write the evaluator.

```haskell
data Term a
  = Lit a
  | Succ (Term a)
  | IsZero (Term a)

-- can't be well-typed :(
eval (Lit i)      = i
eval (Succ t)     = 1 + eval t
eval (IsZero i)   = eval i == 0
```

And we admit the construction of meaningless terms which forces more error
handling cases.

```haskell
-- This is a valid type.
failure = Succ ( Lit True )
```

Using a GADT we can express the type invariants for our language (i.e. only
type-safe expressions are representable). Pattern matching on this GADTs then
carries type equality constraints without the need for explicit tags.

~~~~ {.haskell include="src/12-gadts/gadt.hs"}
~~~~

This time around:

```haskell
-- This is rejected at compile-time.
failure = Succ ( Lit True )
```

Explicit equality constraints (``a ~ b``) can be added to a function's context.
For example the following expand out to the same types.


```haskell
f :: a -> a -> (a, a)
f :: (a ~ b) => a -> b -> (a,b)
```

```haskell
(Int ~ Int)  => ...
(a ~ Int)    => ...
(Int ~ a)    => ...
(a ~ b)      => ...
(Int ~ Bool) => ... -- Will not typecheck.
```

This is effectively the implementation detail of what GHC is doing behind the
scenes to implement GADTs ( implicitly passing and threading equality terms
around ). If we wanted we could do the same setup that GHC does just using
equality constraints and existential quantification.

```haskell
{-# LANGUAGE GADTs #-}
{-# LANGUAGE ExistentialQuantification #-}

-- Using Constraints
data Exp a
  = (a ~ Int) => LitInt a
  | (a ~ Bool) => LitBool a
  | forall b. (b ~ Bool) => If (Exp b) (Exp a) (Exp a)

-- Using GADTs
-- data Exp a where
--   LitInt  :: Int  -> Exp Int
--   LitBool :: Bool -> Exp Bool
--   If      :: Exp Bool -> Exp a -> Exp a -> Exp a

eval :: Exp a -> a
eval e = case e of
  LitInt i   -> i
  LitBool b  -> b
  If b tr fl -> if eval b then eval tr else eval fl

```

In the presence of GADTs inference becomes intractable in many cases, often
requiring an explicit annotation. For example ``f`` can either have ``T a ->
[a]`` or ``T a -> [Int]`` and neither is principal.

```haskell
data T :: * -> * where
  T1 :: Int -> T Int
  T2 :: T a

f (T1 n) = [n]
f T2     = []
```

Kind Signatures
---------------

Haskell's kind system (i.e. the "type of the types") is a system consisting the
single kind ``*`` and an arrow kind ``->``.

```haskell
κ : *
  | κ -> κ
```

```haskell
Int :: *
Maybe :: * -> *
Either :: * -> * -> *
```

There are in fact some extensions to this system that will be covered later ( see:
PolyKinds and Unboxed types in later sections ) but most kinds in everyday code
are simply either stars or arrows.

With the KindSignatures extension enabled we can now annotate top level type
signatures with their explicit kinds, bypassing the normal kind inference
procedures.

```haskell
{-# LANGUAGE KindSignatures #-}

id :: forall (a :: *). a -> a
id x = x
```

On top of default GADT declaration we can also constrain the parameters of the
GADT to specific kinds. For basic usage Haskell's kind inference can deduce this
reasonably well, but combined with some other type system extensions that extend
the kind system this becomes essential.

~~~~ {.haskell include="src/12-gadts/kindsignatures.hs"}
~~~~

Void
----

The Void type is the type with no inhabitants. It unifies only with itself.

Using a newtype wrapper we can create a type where recursion makes it impossible
to construct an inhabitant.

```haskell
-- Void :: Void -> Void
newtype Void = Void Void
```

Or using ``-XEmptyDataDecls`` we can also construct the uninhabited type
equivalently as a data declaration with no constructors.

```haskell
data Void
```

The only inhabitant of both of these types is a diverging term like
(``undefined``).

Phantom Types
-------------

Phantom types are parameters that appear on the left hand side of a type declaration but which are not
constrained by the values of the types inhabitants. They are effectively slots for us to encode additional
information at the type-level.

~~~~ {.haskell include="src/12-gadts/phantom.hs"}
~~~~

Notice the type variable ``tag`` does not appear in the right hand side of the declaration. Using this allows us
to express invariants at the type-level that need not manifest at the value-level. We're effectively
programming by adding extra information at the type-level.

See: [Fun with Phantom Types](http://www.researchgate.net/publication/228707929_Fun_with_phantom_types/file/9c960525654760c169.pdf)


Type Equality
-------------

With a richer language for datatypes we can express terms that witness the
relationship between terms in the constructors, for example we can now express a
term which expresses propositional equality between two types.

The type ``Eql a b`` is a proof that types ``a`` and ``b`` are equal, by pattern
matching on the single ``Refl`` constructor we introduce the equality constraint
into the body of the pattern match.

~~~~ {.haskell include="src/12-gadts/equal.hs"}
~~~~

As of GHC 7.8 these constructors and functions are included in the Prelude in the
[Data.Type.Equality](http://hackage.haskell.org/package/base-4.7.0.0/docs/Data-Type-Equality.html) module.

Interpreters
============

The lambda calculus forms the theoretical and practical foundation for many languages. At the heart of every
calculus is three components:

- **Var** - A variable
- **Lam** - A lambda abstraction
- **App** - An application

![](img/lambda.png)

There are many different ways of modeling these constructions and data structure representations, but they all
more or less contain these three elements. For example, a lambda calculus that uses String names on lambda binders
and variables might be written like the following:

```haskell
type Name = String

data Exp
  = Var Name
  | Lam Name Exp
  | App Exp Exp
```

A lambda expression in which all variables that appear in the body of the expression are referenced in an
outer lambda binder is said to be *closed* while an expression with unbound free variables is *open*.

See: [Mogensen–Scott encoding](http://en.wikipedia.org/wiki/Mogensen-Scott_encoding)

HOAS
----

Higher Order Abstract Syntax (*HOAS*) is a technique for implementing the lambda
calculus in a language where the binders of the lambda expression map directly
onto lambda binders of the host language ( i.e. Haskell ) to give us
substitution machinery in our custom language by exploiting Haskell's
implementation.

~~~~ {.haskell include="src/13-lambda-calculus/hoas.hs"}
~~~~

Pretty printing HOAS terms can also be quite complicated since the body of the
function is under a Haskell lambda binder.

PHOAS
-----

A slightly different form of HOAS called PHOAS uses lambda datatype parameterized over the binder type. In
this form evaluation requires unpacking into a separate Value type to wrap the lambda expression.

~~~~ {.haskell include="src/13-lambda-calculus/phoas.hs"}
~~~~

See:

* [PHOAS](http://adam.chlipala.net/papers/PhoasICFP08/PhoasICFP08Talk.pdf)
* [Encoding Higher-Order Abstract Syntax with Parametric Polymorphism](http://www.seas.upenn.edu/~sweirich/papers/itabox/icfp-published-version.pdf)


Final Interpreters
------------------

Using typeclasses we can implement a *final interpreter* which models a set of
extensible terms using functions bound to typeclasses rather than data
constructors. Instances of the typeclass form interpreters over these terms.

For example we can write a small language that includes basic arithmetic, and
then retroactively extend our expression language with a multiplication operator
without changing the base. At the same time our interpreter logic
remains invariant under extension with new expressions.

~~~~ {.haskell include="src/14-interpreters/fext.hs"}
~~~~

Finally Tagless
---------------

Writing an evaluator for the lambda calculus can likewise also be modeled with a final interpreter and a
Identity functor.

~~~~ {.haskell include="src/14-interpreters/final.hs"}
~~~~

See: [Typed Tagless Interpretations and Typed Compilation](http://okmij.org/ftp/tagless-final/)

Datatypes
---------

The usual hand-wavy of describing algebraic datatypes is to indicate the how natural correspondence between
sum types, product types, and polynomial expressions arises.

```haskell
data Void                       -- 0
data Unit     = Unit            -- 1
data Sum a b  = Inl a | Inr b   -- a + b
data Prod a b = Prod a b        -- a * b
type (->) a b = a -> b          -- b ^ a
```

Intuitively it follows the notion that the cardinality of set of inhabitants of a type can always be given as
a function of the number of its holes. A product type admits a number of inhabitants as a function of the
product (i.e. cardinality of the Cartesian product), a sum type as the sum of its holes and a function
type as the exponential of the span of the domain and codomain.

```haskell
-- 1 + A
data Maybe a = Nothing | Just a
```

Recursive types are correspond to infinite series of these terms.

```haskell
-- pseudocode

-- μX. 1 + X
data Nat a = Z | S Nat
Nat a = μ a. 1 + a
      = 1 + (1 + (1 + ...))

-- μX. 1 + A * X
data List a = Nil | Cons a (List a)
List a = μ a. 1 + a * (List a)
       = 1 + a + a^2 + a^3 + a^4 ...

-- μX. A + A*X*X
data Tree a f = Leaf a | Tree a f f
Tree a = μ a. 1 + a * (List a)
       = 1 + a^2 + a^4 + a^6 + a^8 ...
```

See: [Species and Functors and Types, Oh My!](http://www.cis.upenn.edu/~byorgey/papers/species-pearl.pdf)

F-Algebras
-----------

The *initial algebra* approach differs from the final interpreter approach in
that we now represent our terms as algebraic datatypes and the interpreter
implements recursion and evaluation occurs through pattern matching.

```haskell
type Algebra f a = f a -> a
type Coalgebra f a = a -> f a
newtype Fix f = Fix { unFix :: f (Fix f) }

cata :: Functor f => Algebra f a -> Fix f -> a
ana  :: Functor f => Coalgebra f a -> a -> Fix f
hylo :: Functor f => Algebra f b -> Coalgebra f a -> a -> b
```

In Haskell a F-algebra is a functor ``f a`` together with a function ``f a -> a``.
A coalgebra reverses the function. For a functor ``f`` we can form its
recursive unrolling using the recursive ``Fix`` newtype wrapper.


```haskell
newtype Fix f = Fix { unFix :: f (Fix f) }

Fix :: f (Fix f) -> Fix f
unFix :: Fix f -> f (Fix f)
```

```haskell
Fix f = f (f (f (f (f (f ( ... ))))))

newtype T b a = T (a -> b)

Fix (T a)
Fix T -> a
(Fix T -> a) -> a
(Fix T -> a) -> a -> a
...
```

In this form we can write down a generalized fold/unfold function that are datatype generic and written purely
in terms of the recursing under the functor.

```haskell
cata :: Functor f => Algebra f a -> Fix f -> a
cata alg = alg . fmap (cata alg) . unFix

ana :: Functor f => Coalgebra f a -> a -> Fix f
ana coalg = Fix . fmap (ana coalg) . coalg
```

We call these functions *catamorphisms* and *anamorphisms*. Notice especially that the types of these two
functions simply reverse the direction of arrows. Interpreted in another way they transform an
algebra/coalgebra which defines a flat structure-preserving mapping between ``Fix f`` ``f`` into a function
which either rolls or unrolls the fixpoint. What is particularly nice about this approach is that the
recursion is abstracted away inside the functor definition and we are free to just implement the flat
transformation logic!

For example a construction of the natural numbers in this form:

~~~~ {.haskell include="src/14-interpreters/initial.hs"}
~~~~

Or for example an interpreter for a small expression language that depends on a
scoping dictionary.

~~~~ {.haskell include="src/14-interpreters/initial_interpreter.hs"}
~~~~

What's especially nice about this approach is how naturally catamorphisms
compose into efficient composite transformations.

```haskell
compose :: Functor f => (f (Fix f) -> c) -> (a -> Fix f) -> a -> c
compose f g = f . unFix . g
```

* [Understanding F-Algebras](https://www.fpcomplete.com/user/bartosz/understanding-algebras)

recursion-schemes
-----------------

The code from the F-algebra examples above is implemented in an off-the-shelf
library called ``recursion-schemes``.

~~~~ {.haskell include="src/14-interpreters/recursion_schemes.hs"}
~~~~

An example of usage:

~~~~ {.haskell include="src/14-interpreters/catamorphism.hs"}
~~~~

See:

* [recursion-schemes](http://hackage.haskell.org/package/recursion-schemes)

Hint and Mueval
---------------

GHC itself can actually interpret arbitrary Haskell source on the fly by
hooking into the GHC's bytecode interpreter ( the same used for GHCi ). The hint
package allows us to parse, typecheck, and evaluate arbitrary strings into
arbitrary Haskell programs and evaluate them.

```haskell
import Language.Haskell.Interpreter

foo :: Interpreter String
foo = eval "(\\x -> x) 1"

example :: IO (Either InterpreterError String)
example = runInterpreter foo
```

This is generally not a wise thing to build a library around, unless of course
the purpose of the program is itself to evaluate arbitrary Haskell code (
something like an online Haskell shell or the likes ).

Both hint and mueval do effectively the same task, designed around slightly
different internals of the GHC Api.

See:

* [hint](http://hackage.haskell.org/package/mueval)
* [mueval](http://hackage.haskell.org/package/mueval)

Testing
=======

Contrary to a lot of misinformation, unit testing in Haskell is quite common and robust. Although generally
speaking unit tests tend to be of less importance in Haskell since the type system makes an enormous amount of
invalid programs completely inexpressible by construction. Unit tests tend to be written later in the
development lifecycle and generally tend to be about the core logic of the program and not the intermediate
plumbing.

A prominent school of thought on Haskell library design tends to favor constructing programs built around
strong equation laws which guarantee strong invariants about program behavior under composition. Many of the
testing tools are built around this style of design.

QuickCheck
----------

Probably the most famous Haskell library, QuickCheck is a testing framework for generating large random tests
for arbitrary functions automatically based on the types of their arguments.

```haskell
quickCheck :: Testable prop => prop -> IO ()
(==>) :: Testable prop => Bool -> prop -> Property
forAll :: (Show a, Testable prop) => Gen a -> (a -> prop) -> Property
choose :: Random a => (a, a) -> Gen a
```

~~~~ {.haskell include="src/15-testing/qcheck.hs"}
~~~~

```bash
$ runhaskell qcheck.hs
*** Failed! Falsifiable (after 3 tests and 4 shrinks):
[0]
[1]

$ runhaskell qcheck.hs
+++ OK, passed 1000 tests.
```

The test data generator can be extended with custom types and refined with predicates that restrict the domain
of cases to test.

~~~~ {.haskell include="src/15-testing/arbitrary.hs"}
~~~~

See: [QuickCheck: An Automatic Testing Tool for Haskell](http://www.cse.chalmers.se/~rjmh/QuickCheck/manual.html)

SmallCheck
----------

Like QuickCheck, SmallCheck is a property testing system but instead of producing random arbitrary test data
it instead enumerates a deterministic series of test data to a fixed depth.

```haskell
smallCheck :: Testable IO a => Depth -> a -> IO ()
list :: Depth -> Series Identity a -> [a]
sample' :: Gen a -> IO [a]
```

```haskell
λ: list 3 series :: [Int]
[0,1,-1,2,-2,3,-3]

λ: list 3 series :: [Double]
[0.0,1.0,-1.0,2.0,0.5,-2.0,4.0,0.25,-0.5,-4.0,-0.25]

λ: list 3 series :: [(Int, String)]
[(0,""),(1,""),(0,"a"),(-1,""),(0,"b"),(1,"a"),(2,""),(1,"b"),(-1,"a"),(-2,""),(-1,"b"),(2,"a"),(-2,"a"),(2,"b"),(-2,"b")]
```

It is useful to generate test cases over *all* possible inputs of a program up to some depth.

~~~~ {.haskell include="src/15-testing/smallcheck.hs"}
~~~~

```haskell
$ runhaskell smallcheck.hs
Testing distributivity...
Completed 132651 tests without failure.

Testing Cauchy-Schwarz...
Completed 27556 tests without failure.

Testing invalid Cauchy-Schwarz...
Failed test no. 349.
there exist [1.0] [0.5] such that
  condition is false
```

Just like for QuickCheck we can implement series instances for our custom datatypes. For example there is no
default instance for Vector, so let's implement one:

~~~~ {.haskell include="src/15-testing/smallcheck_series.hs"}
~~~~

SmallCheck can also use Generics to derive Serial instances, for example to enumerate all trees of a certain
depth we might use:

~~~~ {.haskell include="src/15-testing/smallcheck_tree.hs"}
~~~~

QuickSpec
---------

Using the QuickCheck arbitrary machinery we can also rather remarkably enumerate a large number of
combinations of functions to try and deduce algebraic laws from trying out inputs for small cases.

Of course the fundamental limitation of this approach is that a function may not exhibit any interesting
properties for small cases or for simple function compositions. So in general case this approach won't work,
but practically it still quite useful.

~~~~ {.haskell include="src/15-testing/quickspec.hs"}
~~~~

Running this we rather see it is able to deduce most of the laws for list functions.

```bash
$ runhaskell src/quickspec.hs
== API ==
-- functions --
map :: (A -> A) -> [A] -> [A]
minimum :: [A] -> A
(++) :: [A] -> [A] -> [A]
length :: [A] -> Int
sort, id, reverse :: [A] -> [A]

-- background functions --
id :: A -> A
(:) :: A -> [A] -> [A]
(.) :: (A -> A) -> (A -> A) -> A -> A
[] :: [A]

-- variables --
f, g, h :: A -> A
xs, ys, zs :: [A]

-- the following types are using non-standard equality --
A -> A

-- WARNING: there are no variables of the following types; consider adding some --
A

== Testing ==
Depth 1: 12 terms, 4 tests, 24 evaluations, 12 classes, 0 raw equations.
Depth 2: 80 terms, 500 tests, 18673 evaluations, 52 classes, 28 raw equations.
Depth 3: 1553 terms, 500 tests, 255056 evaluations, 1234 classes, 319 raw equations.
319 raw equations; 1234 terms in universe.

== Equations about map ==
  1: map f [] == []
  2: map id xs == xs
  3: map (f.g) xs == map f (map g xs)

== Equations about minimum ==
  4: minimum [] == undefined

== Equations about (++) ==
  5: xs++[] == xs
  6: []++xs == xs
  7: (xs++ys)++zs == xs++(ys++zs)

== Equations about sort ==
  8: sort [] == []
  9: sort (sort xs) == sort xs

== Equations about id ==
 10: id xs == xs

== Equations about reverse ==
 11: reverse [] == []
 12: reverse (reverse xs) == xs

== Equations about several functions ==
 13: minimum (xs++ys) == minimum (ys++xs)
 14: length (map f xs) == length xs
 15: length (xs++ys) == length (ys++xs)
 16: sort (xs++ys) == sort (ys++xs)
 17: map f (reverse xs) == reverse (map f xs)
 18: minimum (sort xs) == minimum xs
 19: minimum (reverse xs) == minimum xs
 20: minimum (xs++xs) == minimum xs
 21: length (sort xs) == length xs
 22: length (reverse xs) == length xs
 23: sort (reverse xs) == sort xs
 24: map f xs++map f ys == map f (xs++ys)
 25: reverse xs++reverse ys == reverse (ys++xs)
```

Keep in mind the rather remarkable fact that this is all deduced automatically
from the types alone!

Criterion
---------

Criterion is a statistically aware benchmarking tool.

```haskell
whnf :: (a -> b) -> a -> Pure
nf :: NFData b => (a -> b) -> a -> Pure
nfIO :: NFData a => IO a -> IO ()
bench :: Benchmarkable b => String -> b -> Benchmark
```

~~~~ {.haskell include="src/15-testing/criterion.hs"}
~~~~

```haskell
$ runhaskell criterion.hs
warming up
estimating clock resolution...
mean is 2.349801 us (320001 iterations)
found 1788 outliers among 319999 samples (0.6%)
  1373 (0.4%) high severe
estimating cost of a clock call...
mean is 65.52118 ns (23 iterations)
found 1 outliers among 23 samples (4.3%)
  1 (4.3%) high severe

benchmarking naive/fib 10
mean: 9.903067 us, lb 9.885143 us, ub 9.924404 us, ci 0.950
std dev: 100.4508 ns, lb 85.04638 ns, ub 123.1707 ns, ci 0.950

benchmarking naive/fib 20
mean: 120.7269 us, lb 120.5470 us, ub 120.9459 us, ci 0.950
std dev: 1.014556 us, lb 858.6037 ns, ub 1.296920 us, ci 0.950

benchmarking de moivre/fib 10
mean: 7.699219 us, lb 7.671107 us, ub 7.802116 us, ci 0.950
std dev: 247.3021 ns, lb 61.66586 ns, ub 572.1260 ns, ci 0.950
found 4 outliers among 100 samples (4.0%)
  2 (2.0%) high mild
  2 (2.0%) high severe
variance introduced by outliers: 27.726%
variance is moderately inflated by outliers

benchmarking de moivre/fib 20
mean: 8.082639 us, lb 8.018560 us, ub 8.350159 us, ci 0.950
std dev: 595.2161 ns, lb 77.46251 ns, ub 1.408784 us, ci 0.950
found 8 outliers among 100 samples (8.0%)
  4 (4.0%) high mild
  4 (4.0%) high severe
variance introduced by outliers: 67.628%
variance is severely inflated by outliers
```

Criterion can also generate a HTML page containing the benchmark results plotted

```bash
$ ghc -O2 --make criterion.hs
$ ./criterion -o bench.html
```

![](img/criterion.png)

Tasty
-----

Tasty combines all of the testing frameworks into a common API for forming runnable batches of tests and
collecting the results.

~~~~ {.haskell include="src/15-testing/tasty.hs"}
~~~~

```bash
$ runhaskell TestSuite.hs
Unit tests
  Units
    Equality:        OK
    Assertion:       OK
  QuickCheck tests
    Quickcheck test: OK
      +++ OK, passed 100 tests.
  SmallCheck tests
    Negation:        OK
      11 tests completed
```

Type Families
=============

MultiParam Typeclasses
----------------------

Resolution of vanilla Haskell 98 typeclasses proceeds via very simple context
reduction that minimizes interdependency between predicates, resolves
superclasses, and reduces the types to head normal form. For example:

```haskell
(Eq [a], Ord [a]) => [a]
==> Ord a => [a]
```

If a single parameter typeclass expresses a property of a type ( i.e. it's in a
class or not in class ) then a multiparameter typeclass expresses relationships
between types. For example if we wanted to express the relation a type
can be converted to another type we might use a class like:

~~~~ {.haskell include="src/16-type-families/mparam.hs"}
~~~~

Of course now our instances for ``Convertible Int`` are not unique anymore, so
there no longer exists a nice procedure for determining the inferred type of
``b`` from just ``a``. To remedy this let's add a functional dependency ``a ->
b``, which tells GHC that an instance ``a`` uniquely determines the
instance that b can be.  So we'll see that our two instances relating ``Int`` to
both ``Integer`` and ``Char`` conflict.

~~~~ {.haskell include="src/16-type-families/mparam_fun.hs"}
~~~~

```haskell
Functional dependencies conflict between instance declarations:
  instance Convertible Int Integer
  instance Convertible Int Char
```

Now there's a simpler procedure for determining instances uniquely and
multiparameter typeclasses become more usable and inferable again. Effectively a
functional dependency ``| a -> b`` says that we can't define multiple
multiparamater typeclass instances with the same ``a`` but different ``b``.

```haskell
λ: convert (42 :: Int)
'*'
λ: convert '*'
42
```

Now let's make things not so simple. Turning on ``UndecidableInstances`` loosens
the constraint on context reduction that can only allow constraints of the class to
become structural smaller than its head. As a result implicit computation can
now occur *within in the type class instance search*. Combined with a type-level
representation of Peano numbers we find that we can encode basic arithmetic at
the type-level.

~~~~ {.haskell include="src/16-type-families/fundeps.hs"}
~~~~

If the typeclass contexts look similar to Prolog you're not wrong, if one reads
the contexts qualifier ``(=>)`` backwards as turnstiles ``:-`` then
it's precisely the same equations.

```prolog
add(0, A, A).
add(s(A), B, s(C)) :- add(A, B, C).

pred(0, 0).
pred(S(A), A).
```

This is kind of abusing typeclasses and if used carelessly it can fail to
terminate or overflow at compile-time. ``UndecidableInstances`` shouldn't be
turned on without careful forethought about what it implies.

```haskell
<interactive>:1:1:
    Context reduction stack overflow; size = 201
```

Type Families
-------------

Type families allows us to write functions in the type domain which take types
as arguments which can yield either types or values indexed on their arguments
which are evaluated at compile-time in during typechecking.  Type families come
in two varieties: **data families** and **type synonym families**.

* **type families** are named function on types
* **data families** are type-indexed data types

First let's look at *type synonym families*, there are two equivalent syntactic
ways of constructing them.  Either as *associated* type families declared within
a typeclass or as standalone declarations at the toplevel. The following forms
are semantically equivalent, although the unassociated form is strictly more
general:

```haskell
-- (1) Unassociated form
type family Rep a
type instance Rep Int = Char
type instance Rep Char = Int

class Convertible a where
  convert :: a -> Rep a

instance Convertible Int where
  convert = chr

instance Convertible Char where
  convert = ord



-- (2) Associated form
class Convertible a where
  type Rep a
  convert :: a -> Rep a

instance Convertible Int where
  type Rep Int = Char
  convert = chr

instance Convertible Char where
  type Rep Char = Int
  convert = ord
```

Using the same example we used for multiparameter + functional dependencies
illustration we see that there is a direct translation between the type family
approach and functional dependencies. These two approaches have the same
expressive power.

An associated type family can be queried using the ``:kind!`` command in GHCi.

```haskell
λ: :kind! Rep Int
Rep Int :: *
= Char
λ: :kind! Rep Char
Rep Char :: *
= Int
```

*Data families* on the other hand allow us to create new type parameterized data
constructors. Normally we can only define typeclasses functions whose behavior
results in a uniform result which is purely a result of the typeclasses
arguments. With data families we can allow specialized behavior indexed on the
type.

For example if we wanted to create more complicated vector structures (
bit-masked vectors, vectors of tuples, ... ) that exposed a uniform API but
internally handled the differences in their data layout we can use data families
to accomplish this:

~~~~ {.haskell include="src/16-type-families/datafamily.hs"}
~~~~

Injectivity
-----------

The type level functions defined by type-families are not necessarily
*injective*, the function may map two distinct input types to the same output
type. This differs from the behavior of type constructors ( which are also
type-level functions ) which are injective.

For example for the constructor ``Maybe``,  ``Maybe t1 = Maybe t2`` implies that
``t1 = t2``.

```haskell
data Maybe a = Nothing | Just a
-- Maybe a ~ Maybe b  implies  a ~ b

type instance F Int = Bool
type instance F Char = Bool

-- F a ~ F b does not imply  a ~ b, in general
```

Roles
-----

Roles are a further level of specification for type variables parameters of
datatypes.

* ``nominal``
* ``representational``
* ``phantom``

They were added to the language to address a rather nasty and long-standing bug
around the correspondence between a newtype and its runtime representation. The
fundamental distinction that roles introduce is there are two notions of type
equality:

* ``nominal`` - Two types are the same.
* ``representational`` - Two types have the same runtime representation.

~~~~ {.haskell include="src/16-type-families/roles.hs"}
~~~~

Roles are normally inferred automatically, but with the
``RoleAnnotations`` extension they can be manually annotated. Except in rare
cases this should not be necessary although it is helpful to know what is going
on under the hood.

~~~~ {.haskell include="src/16-type-families/role_infer.hs"}
~~~~

See:

* [Roles: A New Feature of GHC](http://typesandkinds.wordpress.com/2013/08/15/roles-a-new-feature-of-ghc/)
* [Roles](https://ghc.haskell.org/trac/ghc/wiki/Roles)

Monotraversable
---------------

Using type families, mono-traversable generalizes the notion of Functor,
Foldable, and Traversable to include both monomorphic and polymorphic types.

```haskell
omap :: MonoFunctor mono => (Element mono -> Element mono) -> mono -> mono

otraverse :: (Applicative f, MonoTraversable mono)
          => (Element mono -> f (Element mono)) -> mono -> f mono

ofoldMap :: (Monoid m, MonoFoldable mono)
         => (Element mono -> m) -> mono -> m
ofoldl' :: MonoFoldable mono
        => (a -> Element mono -> a) -> a -> mono -> a
ofoldr :: MonoFoldable mono
        => (Element mono -> b -> b) -> b -> mono -> b
```

For example the text type normally does not admit any of these
type-classes since, but now we can write down the instances that model the
interface of Foldable and Traversable.

~~~~ {.haskell include="src/16-type-families/mono.hs"}
~~~~

See: [From Semigroups to Monads](http://fundeps.com/tables/FromSemigroupToMonads.pdf)

NonEmpty
--------

Rather than having degenerate (and often partial) cases of many of the Prelude
functions to accommodate the null case of lists, it is sometimes preferable to
statically enforce empty lists from even being constructed as an inhabitant of a
type.

```haskell
infixr 5 :|, <|
data NonEmpty a = a :| [a]

head :: NonEmpty a -> a
toList :: NonEmpty a -> [a]
fromList :: [a] -> NonEmpty a
```

```haskell
head :: NonEmpty a -> a
head ~(a :| _) = a
```

~~~~ {.haskell include="src/16-type-families/noempty.hs"}
~~~~

In GHC 7.8 ``-XOverloadedLists`` can be used to avoid the extraneous ``fromList`` and ``toList`` conversions.

Manual Proofs
-------------

One of most deep results in computer science, the [Curry–Howard
correspondence](https://en.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence),
is the relation that logical propositions can be modeled by types and
instantiating those types constitute proofs of these propositions. Programs are
proofs and proofs are programs.

Types       Logic
-------     -----------
``A``       proposition
``a : A``   proof
``B(x)``    predicate
``Void``    ⊥
``Unit``    ⊤
``A + B``   A ∨ B
``A × B``   A ∧ B
``A -> B``  A ⇒ B

In dependently typed languages we can exploit this result to its full extent,
in Haskell we don't have the strength that dependent types provide but can still
prove trivial results. For example, now we can model a type level function for
addition and provide a small proof that zero is an additive identity.

```haskell
P 0                   [ base step ]
∀n. P n  → P (1+n)    [ inductive step ]
-------------------
∀n. P(n)
```

```haskell
Axiom 1: a + 0 = a
Axiom 2: a + suc b = suc (a + b)

  0 + suc a
= suc (0 + a)  [by Axiom 2]
= suc a        [Induction hypothesis]
∎
```

Translated into Haskell our axioms are simply type definitions and recursing
over the inductive datatype constitutes the inductive step of our proof.

~~~~ {.haskell include="src/16-type-families/proof.hs"}
~~~~

Using the ``TypeOperators`` extension we can also use infix notation at the
type-level.

```haskell
data a :=: b where
  Refl :: a :=: a

cong :: a :=: b -> (f a) :=: (f b)
cong Refl = Refl

type family (n :: Nat) :+ (m :: Nat) :: Nat
type instance Zero     :+ m = m
type instance (Succ n) :+ m = Succ (n :+ m)

plus_suc :: forall n m. SNat n -> SNat m -> (n :+ (S m)) :=: (S (n :+ m))
plus_suc Zero m = Refl
plus_suc (Succ n) m = cong (plus_suc n m)
```

Constraint Kinds
----------------

GHC's implementation also exposes the predicates that bound quantifiers in
Haskell as types themselves, with the ``-XConstraintKinds`` extension enabled.
Using this extension we work with constraints as first class types.

```haskell
Num :: * -> Constraint
Odd :: * -> Constraint
```

```haskell
type T1 a = (Num a, Ord a)
```

The empty constraint set is indicated by  ``() :: Constraint``.

For a contrived example if we wanted to create a generic ``Sized`` class that
carried with it constraints on the elements of the container in question we
could achieve this quite simply using type families.

~~~~ {.haskell include="src/16-type-families/constraintkinds.hs"}
~~~~

One use-case of this is to capture the typeclass dictionary constrained by a
function and reify it as a value.

~~~~ {.haskell include="src/16-type-families/dict.hs"}
~~~~

Both Constraints and AnyK types are somewhat unique in the Haskell
implementation, in that they have the ``BOX`` kind.

```haskell
λ: import GHC.Prim

λ: :kind AnyK
AnyK :: BOX

λ: :kind Constraint
Constraint :: BOX
```

Promotion
=========

Higher Kinds
------------

The kind system in Haskell is unique by contrast with most other languages in that it allows
datatypes to be constructed which take types and type constructor to other
types. Such a system is said to support *higher kinded types*.

All kind annotations in Haskell necessarily result in a kind ``*`` although any
terms to the left may be higher-kinded (``* -> *``).

The common example is the Monad which has kind ``* -> *``. But we have also seen
this higher-kindedness in free monads.

```haskell
data Free f a where
  Pure :: a -> Free f a
  Free :: f (Free f a) -> Free f a

data Cofree f a where
  Cofree :: a -> f (Cofree f a) -> Cofree f a
```

```haskell
Free :: (* -> *) -> * -> *
Cofree :: (* -> *) -> * -> *
```

For instance ``Cofree Maybe a`` for some monokinded type ``a`` models a
non-empty list with ``Maybe :: * -> *``.

```haskell
-- Cofree Maybe a is a non-empty list
testCofree :: Cofree Maybe Int
testCofree = (Cofree 1 (Just (Cofree 2 Nothing)))
```

Kind Polymorphism
-----------------

The regular value level function which takes a function and applies it to an argument is universally
generalized over in the usual Hindley-Milner way.

```haskell
app :: forall a b. (a -> b) -> a -> b
app f a = f a
```

But when we do the same thing at the type-level we see we lose information about the polymorphism of the
constructor applied.

```haskell
-- TApp :: (* -> *) -> * -> *
data TApp f a = MkTApp (f a)
```

Turning on ``-XPolyKinds`` allows polymorphic variables at the kind level as well.

```haskell
-- Default:   (* -> *) -> * -> *
-- PolyKinds: (k -> *) -> k -> *
data TApp f a = MkTApp (f a)

-- Default:   ((* -> *) -> (* -> *)) -> (* -> *)
-- PolyKinds: ((k -> *) -> (k -> *)) -> (k -> *)
data Mu f a = Roll (f (Mu f) a)

-- Default:   * -> *
-- PolyKinds: k -> *
data Proxy a = Proxy
```

Using the polykinded ``Proxy`` type allows us to write down type class functions over constructors of
arbitrary kind arity.

~~~~ {.haskell include="src/17-promotion/kindpoly.hs"}
~~~~

For example we can write down the polymorphic ``S`` ``K`` combinators at the
type level now.

```haskell
{-# LANGUAGE PolyKinds #-}

newtype I (a :: *) = I a
newtype K (a :: *) (b :: k) = K a
newtype Flip (f :: k1 -> k2 -> *) (x :: k2) (y :: k1) = Flip (f y x)

unI :: I a -> a
unI (I x) = x

unK :: K a b -> a
unK (K x) = x

unFlip :: Flip f x y -> f y x
unFlip (Flip x) = x
```


Data Kinds
----------

The ``-XDataKinds`` extension allows us to use refer to constructors at the value level and the type level.
Consider a simple sum type:

```haskell
data S a b = L a | R b

-- S :: * -> * -> *
-- L :: a -> S a b
-- R :: b -> S a b
```

With the extension enabled we see that our type constructors are now automatically promoted so that ``L``
or ``R`` can be viewed as both a data constructor of the type ``S`` or as the type ``L`` with kind ``S``.

```haskell
{-# LANGUAGE DataKinds #-}

data S a b = L a | R b

-- S :: * -> * -> *
-- L :: * -> S * *
-- R :: * -> S * *
```

Promoted data constructors can referred to in type signatures by prefixing them with a single quote.  Also of
importance is that these promoted constructors are not exported with a module by default, but type synonym
instances can be created using this notation.

```haskell
data Foo = Bar | Baz
type Bar = 'Bar
type Baz = 'Baz
```

Combining this with type families we see we can write meaningful, meaningful type-level functions by
lifting types to the kind level.

~~~~ {.haskell include="src/17-promotion/typefamily.hs"}
~~~~

Vectors
-------

Using this new structure we can create a ``Vec`` type which is parameterized by its length as well as its
element type now that we have a kind language rich enough to encode the successor type in the kind signature
of the generalized algebraic datatype.

~~~~ {.haskell include="src/17-promotion/datakinds.hs"}
~~~~

So now if we try to zip two ``Vec`` types with the wrong shape then we get an error at compile-time about the
off-by-one error.

```haskell
example2 = zipVec vec4 vec5
-- Couldn't match type 'S 'Z with 'Z
-- Expected type: Vec Four Int
--   Actual type: Vec Five Int
```

The same technique we can use to create a container which is statically indexed by an empty or non-empty flag,
such that if we try to take the head of an empty list we'll get a compile-time error, or stated equivalently we
have an obligation to prove to the compiler that the argument we hand to the head function is non-empty.

~~~~ {.haskell include="src/17-promotion/nonempty.hs"}
~~~~

```haskell
Couldn't match type None with Many
Expected type: List NonEmpty Int
  Actual type: List Empty Int
```

See:

* [Giving Haskell a Promotion](https://research.microsoft.com/en-us/people/dimitris/fc-kind-poly.pdf)
* [Faking It: Simulating Dependent Types in Haskell](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.22.2636&rep=rep1&type=pdf)


Typelevel Numbers
-----------------

GHC's type literals can also be used in place of explicit Peano arithmetic.

GHC 7.6 is very conservative about performing reduction, GHC 7.8 is much less so and will can solve many
typelevel constraints involving natural numbers but sometimes still needs a little coaxing.

~~~~ {.haskell include="src/17-promotion/typenat.hs"}
~~~~

~~~~ {.haskell include="src/17-promotion/typenat_cmp.hs"}
~~~~

See: [Type-Level Literals](http://www.haskell.org/ghc/docs/7.8.2/html/users_guide/type-level-literals.html)

Type Equality
-------------

Continuing with the theme of building more elaborate proofs in Haskell, GHC 7.8 recently shipped with the
``Data.Type.Equality`` module which provides us with an extended set of type-level operations for expressing
the equality of types as values, constraints, and promoted booleans.

```haskell
(~)   :: k -> k -> Constraint
(==)  :: k -> k -> Bool
(<=)  :: Nat -> Nat -> Constraint
(<=?) :: Nat -> Nat -> Bool
(+)   :: Nat -> Nat -> Nat
(-)   :: Nat -> Nat -> Nat
(*)   :: Nat -> Nat -> Nat
(^)   :: Nat -> Nat -> Nat
```

```haskell
(:~:)     :: k -> k -> *
Refl      :: a1 :~: a1
sym       :: (a :~: b) -> b :~: a
trans     :: (a :~: b) -> (b :~: c) -> a :~: c
castWith  :: (a :~: b) -> a -> b
gcastWith :: (a :~: b) -> (a ~ b => r) -> r
```

With this we have a much stronger language for writing restrictions that can be checked at a compile-time, and
a mechanism that will later allow us to write more advanced proofs.

~~~~ {.haskell include="src/17-promotion/type_equality.hs"}
~~~~

Proxy
-----

Using kind polymorphism with phantom types allows us to express the Proxy type which is inhabited by a single
constructor with no arguments but with a polykinded phantom type variable which carries an arbitrary type as
the value is passed around.

```haskell
{-# LANGUAGE PolyKinds #-}

-- | A concrete, poly-kinded proxy type
data Proxy t = Proxy
```

```haskell
import Data.Proxy

a :: Proxy ()
a = Proxy

b :: Proxy 3
b = Proxy

c :: Proxy "symbol"
c = Proxy

d :: Proxy Maybe
d = Proxy

e :: Proxy (Maybe ())
e = Proxy
```

This is provided by the Prelude in 7.8.

Promoted Syntax
---------------

We've seen constructors promoted using DataKinds, but just like at the value-level GHC also allows us some
syntactic sugar for list and tuples instead of explicit cons'ing and pair'ing. This is enabled with the
``-XTypeOperators`` extension, which introduces list syntax and tuples of arbitrary arity at the type-level.

```haskell
data HList :: [*] -> * where
  HNil  :: HList '[]
  HCons :: a -> HList t -> HList (a ': t)

data Tuple :: (*,*) -> * where
  Tuple :: a -> b -> Tuple '(a,b)
```

Using this we can construct all variety of composite type-level objects.

```haskell
λ: :kind 1
1 :: Nat

λ: :kind "foo"
"foo" :: Symbol

λ: :kind [1,2,3]
[1,2,3] :: [Nat]

λ: :kind [Int, Bool, Char]
[Int, Bool, Char] :: [*]

λ: :kind Just [Int, Bool, Char]
Just [Int, Bool, Char] :: Maybe [*]

λ: :kind '("a", Int)
(,) Symbol *

λ: :kind [ '("a", Int), '("b", Bool) ]
[ '("a", Int), '("b", Bool) ] :: [(,) Symbol *]
```

Singleton Types
---------------

A singleton type is a type with a single value inhabitant. Singleton types can be constructed in a variety of ways
using GADTs or with data families.

```haskell
data instance Sing (a :: Nat) where
  SZ :: Sing 'Z
  SS :: Sing n -> Sing ('S n)

data instance Sing (a :: Maybe k) where
  SNothing :: Sing 'Nothing
  SJust :: Sing x -> Sing ('Just x)

data instance Sing (a :: Bool) where
  STrue :: Sing True
  SFalse :: Sing False
```

**Promoted Naturals**

```haskell
Value-level  Type-level         Models
-----------  ------------       -------
SZ           Sing 'Z            0
SS SZ        Sing ('S 'Z)       1
SS (SS SZ)   Sing ('S ('S 'Z))  2
```

**Promoted Booleans**

```haskell
Value-level  Type-level         Models
-----------  ---------------    -------
STrue        Sing 'False        False
SFalse       Sing 'True         True
```

**Promoted Maybe**

```haskell
Value-level  Type-level         Models
-----------  ---------------    -------
SJust a      Sing (SJust 'a)    Just a
SNothing     Sing Nothing       Nothing
```

Singleton types are an integral part of the small cottage industry of faking
dependent types in Haskell, i.e.  constructing types with terms predicated upon
values. Singleton types are a way of "cheating" by modeling the map between
types and values as a structural property of the type.

~~~~ {.haskell include="src/17-promotion/singleton_class.hs"}
~~~~

The builtin singleton types provided in ``GHC.TypeLits`` have the useful
implementation that type-level values can be reflected to the value-level and
back up to the type-level, albeit under an existential.

```haskell
someNatVal :: Integer -> Maybe SomeNat
someSymbolVal :: String -> SomeSymbol

natVal :: KnownNat n => proxy n -> Integer
symbolVal :: KnownSymbol n => proxy n -> String
```

~~~~ {.haskell include="src/17-promotion/singleton.hs"}
~~~~

Closed Type Families
--------------------

In the type families we've used so far (called open type families) there is no notion of ordering of the
equations involved in the type-level function. The type family can be extended at any point in the code
resolution simply proceeds sequentially through the available definitions. Closed type-families allow an
alternative declaration that allows for a base case for the resolution allowing us to actually write recursive
functions over types.

For example consider if we wanted to write a function which counts the arguments in the type of a function and
reifies at the value-level.

~~~~ {.haskell include="src/17-promotion/countargs.hs"}
~~~~

The variety of functions we can now write down are rather remarkable, allowing us to write meaningful logic at
the type level.

~~~~ {.haskell include="src/17-promotion/closed_typefamily.hs"}
~~~~

The results of type family functions need not necessarily be kinded as ``(*)`` either. For example using Nat
or Constraint is permitted.

```haskell
type family Elem (a :: k) (bs :: [k]) :: Constraint where
  Elem a (a ': bs) = (() :: Constraint)
  Elem a (b ': bs) = a `Elem` bs

type family Sum (ns :: [Nat]) :: Nat where
  Sum '[] = 0
  Sum (n ': ns) = n + Sum ns
```

Kind Indexed Type Families
--------------------------

Just as typeclasses are normally indexed on types, classes can also be indexed on kinds with the kinds given
as explicit kind signatures on type variables.

```haskell
type family (a :: k) == (b :: k) :: Bool
type instance a == b = EqStar a b
type instance a == b = EqArrow a b
type instance a == b = EqBool a b

type family EqStar (a :: *) (b :: *) where
  EqStar a a = True
  EqStar a b = False

type family EqArrow (a :: k1 -> k2) (b :: k1 -> k2) where
  EqArrow a a = True
  EqArrow a b = False

type family EqBool a b where
  EqBool True  True  = True
  EqBool False False = True
  EqBool a     b     = False

type family EqList a b where
  EqList '[]        '[]        = True
  EqList (h1 ': t1) (h2 ': t2) = (h1 == h2) && (t1 == t2)
  EqList a          b          = False
```

Promoted Symbols
----------------

~~~~ {.haskell include="src/17-promotion/hasfield.hs"}
~~~~

Since record is fundamentally no different from the tuple we can also do the same kind of construction over
record field names.

~~~~ {.haskell include="src/17-promotion/typelevel_fields.hs"}
~~~~

Notably this approach is mostly just all boilerplate class instantiation which could be abstracted away using
TemplateHaskell or a Generic deriving.

HLists
------

A heterogeneous list is a cons list whose type statically encodes the ordered types of its values.

~~~~ {.haskell include="src/17-promotion/hlist.hs"}
~~~~

Of course this immediately begs the question of how to print such a list out to a string in the presence of
type-heterogeneity. In this case we can use type-families combined with constraint kinds to apply the Show
over the HLists parameters to generate the aggregate constraint that all types in the HList are Showable, and
then derive the Show instance.

~~~~ {.haskell include="src/17-promotion/constraint_list.hs"}
~~~~

Typelevel Maps
--------------

Much of this discussion of promotion begs the question whether we can create data structures at the type-level
to store information at compile-time. For example a type-level association list can be used to model a map
between type-level symbols and any other promotable types. Together with type-families we can write down
type-level traversal and lookup functions.

~~~~ {.haskell include="src/17-promotion/typemap.hs"}
~~~~

If we ask GHC to expand out the type signature we can view the explicit implementation of the type-level map
lookup function.

```haskell
(!!)
  :: If
       (GHC.TypeLits.EqSymbol "a" k)
       ('Just 1)
       (If
          (GHC.TypeLits.EqSymbol "b" k)
          ('Just 2)
          (If
             (GHC.TypeLits.EqSymbol "c" k)
             ('Just 3)
             (If (GHC.TypeLits.EqSymbol "d" k) ('Just 4) 'Nothing)))
     ~ 'Just v =>
     Proxy k -> Proxy v
```

Advanced Proofs
---------------

Now that we have the length-indexed vector let's go write the reverse function, how hard could it be?

So we go and write down something like this:

```haskell
reverseNaive :: forall n a. Vec a n -> Vec a n
reverseNaive xs = go Nil xs -- Error: n + 0 != n
  where
    go :: Vec a m -> Vec a n -> Vec a (n :+ m)
    go acc Nil = acc
    go acc (Cons x xs) = go (Cons x acc) xs -- Error: n + succ m != succ (n + m)
```

Running this we find that GHC is unhappy about two lines in the code:

```haskell
Couldn't match type ‘n’ with ‘n :+ 'Z’
    Expected type: Vec a n
      Actual type: Vec a (n :+ 'Z)

Could not deduce ((n1 :+ 'S m) ~ 'S (n1 :+ m))
    Expected type: Vec a1 (k :+ m)
      Actual type: Vec a1 (n1 :+ 'S m)
```

As we unfold elements out of the vector we'll end up a doing a lot of type-level arithmetic over indices as we
combine the subparts of the vector backwards, but as a consequence we find that GHC will run into some
unification errors because it doesn't know about basic arithmetic properties of the natural numbers. Namely
that ``forall n. n + 0 = 0`` and   ``forall n m. n + (1 + m) = 1 + (n + m) ``.  Which of course it really
shouldn't be given that we've constructed a system at the type-level which intuitively *models* arithmetic but
GHC is just a dumb compiler, it can't automatically deduce the isomorphism between natural numbers and Peano
numbers.

So at each of these call sites we now have a proof obligation to construct proof terms which rearrange the
type signatures of the terms in question such that actual types in the error messages GHC gave us align with
the expected values to complete the program.

Recall from our discussion of propositional equality from GADTs that we actually have such machinery to do
this!

~~~~ {.haskell include="src/17-promotion/reverse.hs"}
~~~~

One might consider whether we could avoid using the singleton trick and just use type-level natural numbers,
and technically this approach should be feasible although it seems that the natural number solver in GHC 7.8
can decide some properties but not the ones needed to complete the natural number proofs for the reverse
functions.

```haskell
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ExplicitForAll #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}

import Prelude hiding (Eq)
import GHC.TypeLits
import Data.Type.Equality

type Z = 0

type family S (n :: Nat) :: Nat where
  S n = n + 1

-- Yes!
eq_zero :: Z :~: Z
eq_zero = Refl

-- Yes!
zero_plus_one :: (Z + 1) :~: (1 + Z)
zero_plus_one = Refl

-- Yes!
plus_zero :: forall n. (n + Z) :~: n
plus_zero = Refl

-- Yes!
plus_one :: forall n. (n + S Z) :~: S n
plus_one = Refl

-- No.
plus_suc :: forall n m. (n + (S m)) :~: (S (n + m))
plus_suc = Refl
```

Caveat should be that there might be a way to do this in GHC 7.6 that I'm not
aware of.  In GHC 7.10 there are some planned changes to solver that should be
able to resolve these issues.  In particular there are plans to allow pluggable
type system extensions that could outsource these kind of problems to third
party SMT solvers which can solve these kind of numeric relations and return
this information back to GHC's typechecker.

As an aside this is a direct transliteration of the equivalent proof in Agda,
which is accomplished via the same method but without the song and dance to get
around the lack of dependent types.

~~~~ {.haskell include="src/17-promotion/Vector.agda"}
~~~~

Generics
========

Haskell has several techniques for automatic generation of type classes for a
variety of tasks that consist largely of boilerplate code generation such as:

* Pretty Printing
* Equality
* Serialization
* Ordering
* Traversal

Typeable
--------

The ``Typeable`` class be used to create runtime type information for arbitrary
types.

```haskell
typeOf :: Typeable a => a -> TypeRep
```

~~~~ {.haskell include="src/18-generics/typeable.hs"}
~~~~

Using the Typeable instance allows us to write down a type safe cast function
which can safely use ``unsafeCast`` and provide a proof that the resulting type
matches the input.

```haskell
cast :: (Typeable a, Typeable b) => a -> Maybe b
cast x
  | typeOf x == typeOf ret = Just ret
  | otherwise = Nothing
  where
    ret = unsafeCast x
```

Of historical note is that writing our own Typeable classes is currently
possible of GHC 7.6 but allows us to introduce dangerous behavior that can cause
crashes, and shouldn't be done except by GHC itself. As of 7.8 GHC forbids
hand-written Typeable instances.

See: [Typeable and Data in Haskell](http://chrisdone.com/posts/data-typeable)

Dynamic
-------

Since we have a way of querying runtime type information we can use this
machinery to implement a ``Dynamic`` type. This allows us to box up any monotype
into a uniform type that can be passed to any function taking a Dynamic type
which can then unpack the underlying value in a type-safe way.

```haskell
toDyn :: Typeable a => a -> Dynamic
fromDyn :: Typeable a => Dynamic -> a -> a
fromDynamic :: Typeable a => Dynamic -> Maybe a
cast :: (Typeable a, Typeable b) => a -> Maybe b
```

~~~~ {.haskell include="src/18-generics/dynamic.hs"}
~~~~

In GHC 7.8 the Typeable class is poly-kinded so polymorphic functions can be
applied over dynamic objects.

Data
----

Just as Typeable let's create runtime type information where needed, the Data
class allows us to reflect information about the structure of datatypes to
runtime as needed.

```haskell
class Typeable a => Data a where
  gfoldl  :: (forall d b. Data d => c (d -> b) -> d -> c b)
          -> (forall g. g -> c g)
          -> a
          -> c a

  gunfold :: (forall b r. Data b => c (b -> r) -> c r)
          -> (forall r. r -> c r)
          -> Constr
          -> c a

  toConstr :: a -> Constr
  dataTypeOf :: a -> DataType
  gmapQl :: (r -> r' -> r) -> r -> (forall d. Data d => d -> r') -> a -> r
```

The types for ``gfoldl`` and ``gunfold`` are a little intimidating ( and depend
on ``Rank2Types`` ), the best way to understand is to look at some examples.
First the most trivial case a simple sum type ``Animal`` would produce the following code:

```haskell
data Animal = Cat | Dog deriving Typeable
```

```haskell
instance Data Animal where
  gfoldl k z Cat = z Cat
  gfoldl k z Dog = z Dog

  gunfold k z c
    = case constrIndex c of
        1 -> z Cat
        2 -> z Dog

  toConstr Cat = cCat
  toConstr Dog = cDog

  dataTypeOf _ = tAnimal

tAnimal :: DataType
tAnimal = mkDataType "Main.Animal" [cCat, cDog]

cCat :: Constr
cCat = mkConstr tAnimal "Cat" [] Prefix

cDog :: Constr
cDog = mkConstr tAnimal "Dog" [] Prefix
```

For a type with non-empty containers we get something a little more interesting.
Consider the list type:

```haskell
instance Data a => Data [a] where
  gfoldl _ z []     = z []
  gfoldl k z (x:xs) = z (:) `k` x `k` xs

  toConstr []    = nilConstr
  toConstr (_:_) = consConstr

  gunfold k z c
    = case constrIndex c of
        1 -> z []
        2 -> k (k (z (:)))

  dataTypeOf _ = listDataType

nilConstr :: Constr
nilConstr = mkConstr listDataType "[]" [] Prefix

consConstr :: Constr
consConstr = mkConstr listDataType "(:)" [] Infix

listDataType :: DataType
listDataType = mkDataType "Prelude.[]" [nilConstr,consConstr]
```

Looking at ``gfoldl`` we see the Data has an implementation of a function for us
to walk an applicative over the elements of the constructor by applying a
function ``k`` over each element and applying ``z`` at the spine. For example
look at the instance for a 2-tuple as well:


```haskell
instance (Data a, Data b) => Data (a,b) where
  gfoldl k z (a,b) = z (,) `k` a `k` b

  toConstr (_,_) = tuple2Constr

  gunfold k z c
    = case constrIndex c of
      1 -> k (k (z (,)))

  dataTypeOf _  = tuple2DataType

tuple2Constr :: Constr
tuple2Constr = mkConstr tuple2DataType "(,)" [] Infix

tuple2DataType :: DataType
tuple2DataType = mkDataType "Prelude.(,)" [tuple2Constr]
```

This is pretty neat, now within the same typeclass we have a generic way to
introspect any ``Data`` instance and write logic that depends on the structure
and types of its subterms. We can now write a function which allow us to
traverse an arbitrary instance Data and twiddle values based on pattern matching
on the runtime types. So let's write down a function ``over`` which increments a
``Value`` type for both for n-tuples and lists.

~~~~ {.haskell include="src/18-generics/data.hs"}
~~~~

We can also write generic operations to for instance count the number of
parameters in a data type.

```haskell
numHoles :: Data a => a -> Int
numHoles = gmapQl (+) 0 (const 1)

example1 :: Int
example1 = numHoles (1,2,3,4,5,6,7)
-- 7

example2 :: Int
example2 = numHoles (Just 3)
-- 1
```

This method adapts itself well to generic traversals but the types quickly
become rather hairy when dealing anymore more complicated involving folds and
unsafe coercions.


Generic
-------

The most modern method of doing generic programming uses type families to
achieve a better of deriving the structural properties of arbitrary type
classes.  Generic implements a typeclass with an associated type ``Rep`` (
Representation ) together with a pair of functions that form a 2-sided inverse (
isomorphism ) for converting to and from the associated type and the derived
type in question.

```haskell
class Generic a where
  type Rep a
  from :: a -> Rep a
  to :: Rep a -> a

class Datatype d where
  datatypeName :: t d f a -> String
  moduleName :: t d f a -> String

class Constructor c where
  conName :: t c f a -> String
```

[GHC.Generics](https://www.haskell.org/ghc/docs/7.4.1/html/libraries/ghc-prim-0.2.0.0/GHC-Generics.html)
defines a set of named types for modeling the various structural properties of
types in available in Haskell.

```haskell
-- | Sums: encode choice between constructors
infixr 5 :+:
data (:+:) f g p = L1 (f p) | R1 (g p)

-- | Products: encode multiple arguments to constructors
infixr 6 :*:
data (:*:) f g p = f p :*: g p

-- | Tag for M1: datatype
data D
-- | Tag for M1: constructor
data C

-- | Constants, additional parameters and recursion of kind *
newtype K1 i c p = K1 { unK1 :: c }

-- | Meta-information (constructor names, etc.)
newtype M1 i c f p = M1 { unM1 :: f p }

-- | Type synonym for encoding meta-information for datatypes
type D1 = M1 D

-- | Type synonym for encoding meta-information for constructors
type C1 = M1 C
```

Using the deriving mechanics GHC can generate this Generic instance for us
mechanically, if we were to write it by hand for a simple type it might look
like this:

~~~~ {.haskell include="src/18-generics/generics.hs"}
~~~~

Use ``kind!`` in GHCi we can look at the type family ``Rep`` associated with a Generic instance.

```haskell
λ: :kind! Rep Animal
Rep Animal :: * -> *
= M1 D T_Animal (M1 C C_Dog U1 :+: M1 C C_Cat U1)

λ: :kind! Rep ()
Rep () :: * -> *
= M1 D GHC.Generics.D1() (M1 C GHC.Generics.C1_0() U1)

λ: :kind! Rep [()]
Rep [()] :: * -> *
= M1
    D
    GHC.Generics.D1[]
    (M1 C GHC.Generics.C1_0[] U1
     :+: M1
           C
           GHC.Generics.C1_1[]
           (M1 S NoSelector (K1 R ()) :*: M1 S NoSelector (K1 R [()])))
```

Now the clever bit, instead writing our generic function over the datatype we
instead write it over the Rep and then reify the result using ``from``. Some for
an equivalent version of Haskell's default ``Eq`` that instead uses generic
deriving we could write:

```haskell
class GEq' f where
  geq' :: f a -> f a -> Bool

instance GEq' U1 where
  geq' _ _ = True

instance (GEq c) => GEq' (K1 i c) where
  geq' (K1 a) (K1 b) = geq a b

instance (GEq' a) => GEq' (M1 i c a) where
  geq' (M1 a) (M1 b) = geq' a b

-- Equality for sums.
instance (GEq' a, GEq' b) => GEq' (a :+: b) where
  geq' (L1 a) (L1 b) = geq' a b
  geq' (R1 a) (R1 b) = geq' a b
  geq' _      _      = False

-- Equality for products.
instance (GEq' a, GEq' b) => GEq' (a :*: b) where
  geq' (a1 :*: b1) (a2 :*: b2) = geq' a1 a2 && geq' b1 b2
```

Now to accommodate the two methods of writing classes (generic-deriving or
custom implementations) we can use ``DefaultSignatures`` extension to allow the
user to leave typeclass functions blank and defer to the Generic or to define
their own.

```haskell
{-# LANGUAGE DefaultSignatures #-}

class GEq a where
  geq :: a -> a -> Bool

  default geq :: (Generic a, GEq' (Rep a)) => a -> a -> Bool
  geq x y = geq' (from x) (from y)
```

Now anyone using our library need only derive Generic and create an empty
instance of our typeclass instance without writing any boilerplate for ``GEq``.

See:

* [Andres Loh: Datatype-generic Programming in Haskell](http://www.andres-loeh.de/DGP-Intro.pdf)
* [generic-deriving](http://hackage.haskell.org/package/generic-deriving-1.6.3)


Generic Deriving
----------------

Using Generics, we can ask GHC to do lots of non-trivial code generation which
works spectacularly well in practice. Some real world examples:

The [hashable](http://hackage.haskell.org/package/hashable) library allows us to derive hashing functions.

~~~~ {.haskell include="src/18-generics/hashable.hs"}
~~~~

The [cereal](http://hackage.haskell.org/package/cereal-0.4.0.1) library allows
us to automatically derive a binary representation.

~~~~ {.haskell include="src/18-generics/cereal.hs"}
~~~~

The [aeson](http://hackage.haskell.org/package/aeson) library allows us to
derive JSON representations for JSON instances.

~~~~ {.haskell include="src/18-generics/derive_aeson.hs"}
~~~~

See: [A Generic Deriving Mechanism for Haskell](http://dreixel.net/research/pdf/gdmh.pdf)

Uniplate
--------

Uniplate is a generics library for writing traversals and transformation for
arbitrary data structures. It is extremely useful for writing AST
transformations and rewriting systems.

```haskell
plate :: from -> Type from to
(|*)  :: Type (to -> from) to -> to -> Type from to
(|-)  :: Type (item -> from) to -> item -> Type from to

descend   :: Uniplate on => (on -> on) -> on -> on
transform :: Uniplate on => (on -> on) -> on -> on
rewrite   :: Uniplate on => (on -> Maybe on) -> on -> on
```

The ``descend`` function will apply a function to each immediate descendant of
an expression and then combines them up into the parent expression.

The ``transform`` function will perform a single pass bottom-up transformation
of all terms in the expression.

The ``rewrite`` function will perform an exhaustive transformation of all terms
in the expression to fixed point, using Maybe to signify termination.

~~~~ {.haskell include="src/18-generics/uniplate.hs"}
~~~~

Alternatively Uniplate instances can be derived automatically from instances of
Data without the need to explicitly write a Uniplate instance. This approach
carries a slight amount of overhead over an explicit hand-written instance.

```haskell
import Data.Data
import Data.Typeable
import Data.Generics.Uniplate.Data

data Expr a
  = Fls
  | Tru
  | Lit a
  | Not (Expr a)
  | And (Expr a) (Expr a)
  | Or (Expr a) (Expr a)
  deriving (Data, Typeable, Show, Eq)
```

**Biplate**

Biplates generalize plates where the target type isn't necessarily the same as
the source, it uses multiparameter typeclasses to indicate the type sub of the
sub-target. The Uniplate functions all have an equivalent generalized biplate
form.

```haskell
descendBi   :: Biplate from to => (to -> to) -> from -> from
transformBi :: Biplate from to => (to -> to) -> from -> from
rewriteBi   :: Biplate from to => (to -> Maybe to) -> from -> from

descendBiM   :: (Monad m, Biplate from to) => (to -> m to) -> from -> m from
transformBiM :: (Monad m, Biplate from to) => (to -> m to) -> from -> m from
rewriteBiM   :: (Monad m, Biplate from to) => (to -> m (Maybe to)) -> from -> m from
```

~~~~ {.haskell include="src/18-generics/biplate.hs"}
~~~~

Mathematics
===========

Numeric Tower
-------------

Haskell's numeric tower is unusual and the source of some confusion for novices.
Haskell is one of the few languages to incorporate statically typed overloaded
literals without a mechanism for "coercions" often found in other languages.

To add to the confusion numerical literals in Haskell are desugared into a
function from a numeric typeclass which yields a polymorphic value that can be
instantiated to any instance of the ``Num`` or ``Fractional`` typeclass at the
call-site, depending on the inferred type.

To use a blunt metaphor, we're effectively placing an object in a hole and the
size and shape of the hole defines the object you place there. This is very
different than in other languages where a numeric literal like ``2.718`` is hard
coded in the compiler to be a specific type ( double or something ) and you cast
the value at runtime to be something smaller or larger as needed.

```haskell
42 :: Num a => a
fromInteger (42 :: Integer)

2.71 :: Fractional a => a
fromRational (2.71 :: Rational)
```

The numeric typeclass hierarchy is defined as such:

```haskell
class Num a
class (Num a, Ord a) => Real a
class Num a => Fractional a
class (Real a, Enum a) => Integral a
class (Real a, Fractional a) => RealFrac a
class Fractional a => Floating a
class (RealFrac a, Floating a) => RealFloat a
```

![](img/numerics.png)

Conversions between concrete numeric types ( from : left column, to : top row )
is accomplished with several generic functions.

         Double       Float         Int           Word           Integer       Rational
------   ------       -----         ---           ----           --------      --------
Double   id           fromRational  truncate      truncate       truncate      toRational
Float    fromRational id            truncate      truncate       truncate      toRational
Int      fromIntegral fromIntegral  id            fromIntegral   fromIntegral  fromIntegral
Word     fromIntegral fromIntegral  fromIntegral  id             fromIntegral  fromIntegral
Integer  fromIntegral fromIntegral  fromIntegral  fromIntegral   id            fromIntegral
Rational fromRatoinal fromRational  truncate      truncate       truncate      id

Integer
-------

The ``Integer`` type in GHC is implemented by the GMP (``libgmp``) arbitrary
precision arithmetic library.  Unlike the ``Int`` type the size of Integer
values is bounded only by the available memory. Most notably ``libgmp`` is one
of the few libraries that compiled Haskell binaries are dynamically linked
against.

An alternative library ``integer-simple`` can be linked in place of libgmp.

See: [GHC, primops and exorcising GMP](http://www.well-typed.com/blog/32/)

Complex
-------

Haskell supports arithmetic with complex numbers via a Complex datatype. The
first argument is the real part, while the second is the imaginary.

```haskell
-- 1 + 2i
let complex = 1 :+ 2
```

```haskell
data Complex a = a :+ a
mkPolar :: RealFloat a => a -> a -> Complex a
```

The ``Num`` instance for ``Complex`` is only defined if parameter of ``Complex``
is an instance of ``RealFloat``.

```haskell
λ: 0 :+ 1
0 :+ 1 :: Complex Integer

λ: (0 :+ 1) + (1 :+ 0)
1.0 :+ 1.0 :: Complex Integer

λ: exp (0 :+ 2 * pi)
1.0 :+ (-2.4492935982947064e-16) :: Complex Double

λ: mkPolar 1 (2*pi)
1.0 :+ (-2.4492935982947064e-16) :: Complex Double

λ: let f x n = (cos x :+ sin x)^n
λ: let g x n = cos (n*x) :+ sin (n*x)
```

Scientific
----------

```haskell
scientific :: Integer -> Int -> Scientific
fromFloatDigits :: RealFloat a => a -> Scientific
```

Scientific provides arbitrary-precision numbers represented using scientific
notation. The constructor takes an arbitrarily sized Integer argument for the
digits and an Int for the exponent. Alternatively the value can be parsed from
a String or coerced from either Double/Float.

~~~~ {.haskell include="src/19-numbers/scientific.hs"}
~~~~

Statistics
----------

~~~~ {.haskell include="src/19-numbers/stats.hs"}
~~~~

Constructive Reals
------------------

Instead of modeling the real numbers on finite precision floating point numbers
we alternatively work with ``Num`` which internally manipulate the power
series expansions for the expressions when performing operations like arithmetic
or transcendental functions without losing precision when performing
intermediate computations. Then we simply slice off a fixed number of terms and
approximate the resulting number to a desired precision. This approach is not
without its limitations and caveats ( notably that it may diverge ) but works
quite well in practice.

```haskell
exp(x)    = 1 + x + 1/2*x^2 + 1/6*x^3 + 1/24*x^4 + 1/120*x^5 ...
sqrt(1+x) = 1 + 1/2*x - 1/8*x^2 + 1/16*x^3 - 5/128*x^4 + 7/256*x^5 ...
atan(x)   = x - 1/3*x^3 + 1/5*x^5 - 1/7*x^7 + 1/9*x^9 - 1/11*x^11 ...
pi        = 16 * atan (1/5) - 4 * atan (1/239)
```

~~~~ {.haskell include="src/19-numbers/creal.hs"}
~~~~

SAT Solvers
-----------

A collection of constraint problems known as satisfiability problems show up in
a number of different disciplines from type checking to package management.
Simply put a satisfiability problem attempts to find solutions to a statement
of conjoined conjunctions and disjunctions in terms of a series of variables.
For example:

```text
(A v ¬B v C) ∧ (B v D v E) ∧ (D v F)
```

To use the picosat library to solve this, it can be written as zero-terminated
lists of integers and fed to the solver according to a number-to-variable
relation:

```haskell
1 -2 3  -- (A v ¬B v C)
2 4 5   -- (B v D v E)
4 6     -- (D v F)
```

```haskell
import Picosat

main :: IO [Int]
main = do
  solve [[1, -2, 3], [2,4,5], [4,6]]
  -- Solution [1,-2,3,4,5,6]
```

The SAT solver itself can be used to solve satisfiability problems with millions
of variables in this form and is finely tuned.

See:

* [picosat](http://hackage.haskell.org/package/picosat-0.1.1)

SMT Solvers
-----------

A generalization of the SAT problem to include predicates other theories gives
rise to the very sophisticated domain of "Satisfiability Modulo Theory"
problems. The existing SMT solvers are very sophisticated projects ( usually
bankrolled by large institutions ) and usually have to called out to via foreign
function interface or via a common interface called SMT-lib. The two most common
of use in Haskell are ``cvc4`` from Stanford and ``z3`` from Microsoft Research.

The SBV library can abstract over different SMT solvers to allow us to express
the problem in an embedded domain language in Haskell and then offload the
solving work to the third party library.

TODO: Talk about SBV

See:

* [cvc4](http://cvc4.cs.nyu.edu/web/)
* [z3](http://z3.codeplex.com/)

Data Structures
===============

Map
映射
---

~~~~ {.haskell include="src/20-data-structures/map.hs"}
~~~~

Tree
树
----

~~~~ {.haskell include="src/20-data-structures/tree.hs"}
~~~~

Set
集合
---

~~~~ {.haskell include="src/20-data-structures/set.hs"}
~~~~

Vector
向量
------

Vectors are high performance single dimensional arrays that come come in six variants, two for each of the
following types of a mutable and an immutable variant.

* Data.Vector
* Data.Vector.Storable
* Data.Vector.Unboxed

The most notable feature of vectors is constant time memory access with (``(!)``) as well as variety of
efficient map, fold and scan operations on top of a fusion framework that generates surprisingly optimal code.

```haskell
fromList :: [a] -> Vector a
toList :: Vector a -> [a]
(!) :: Vector a -> Int -> a
map :: (a -> b) -> Vector a -> Vector b
foldl :: (a -> b -> a) -> a -> Vector b -> a
scanl :: (a -> b -> a) -> a -> Vector b -> Vector a
zipWith :: (a -> b -> c) -> Vector a -> Vector b -> Vector c
iterateN :: Int -> (a -> a) -> a -> Vector a
```

~~~~ {.haskell include="src/20-data-structures/vector.hs"}
~~~~

See: [Numerical Haskell: A Vector Tutorial](http://wiki.haskell.org/Numeric_Haskell:_A_Vector_Tutorial)

Mutable Vectors
可变向量
---------------

```haskell
freeze :: MVector (PrimState m) a -> m (Vector a)
thaw :: Vector a -> MVector (PrimState m) a
```

Within the IO monad we can perform arbitrary read and writes on the mutable
vector with constant time reads and writes. When needed a static Vector can be
created to/from the ``MVector`` using the freeze/thaw functions.


~~~~ {.haskell include="src/20-data-structures/vector_mutable.hs"}
~~~~

Unordered-Containers
无序容器
--------------------

```haskell
fromList :: (Eq k, Hashable k) => [(k, v)] -> HashMap k v
lookup :: (Eq k, Hashable k) => k -> HashMap k v -> Maybe v
insert :: (Eq k, Hashable k) => k -> v -> HashMap k v -> HashMap k v
```

Both the ``HashMap`` and ``HashSet`` are purely functional data structures that
are drop in replacements for the ``containers`` equivalents but with more
efficient space and time performance. Additionally all stored elements must have
a ``Hashable`` instance.

~~~~ {.haskell include="src/20-data-structures/unordered.hs"}
~~~~

See: [Johan Tibell: Announcing Unordered Containers](http://blog.johantibell.com/2012/03/announcing-unordered-containers-02.html)

Hashtables
散列表
----------

Hashtables provides hashtables with efficient lookup within the ST or IO monad.

~~~~ {.haskell include="src/20-data-structures/hashtables.hs"}
~~~~

```haskell
new :: ST s (HashTable s k v)
insert :: (Eq k, Hashable k) => HashTable s k v -> k -> v -> ST s ()
lookup :: (Eq k, Hashable k) => HashTable s k v -> k -> ST s (Maybe v)
```

Graphs
图
------

The Graph module in the containers library is a somewhat antiquated API for
working with directed graphs.  A little bit of data wrapping makes it a little
more straightforward to use. The library is not necessarily well-suited for
large graph-theoretic operations but is perfectly fine for example, to use in a
typechecker which need to resolve strongly connected components of the module
definition graph.

~~~~ {.haskell include="src/20-data-structures/graph.hs"}
~~~~

So for example we can construct a simple graph:

![](img/graph1.png)

```haskell
ex1 :: [(String, String, [String])]
ex1 = [
    ("a","a",["b"]),
    ("b","b",["c"]),
    ("c","c",["a"])
  ]

ts1 :: [String]
ts1 = topo' (fromList ex1)
-- ["a","b","c"]

sc1 :: [[String]]
sc1 = scc' (fromList ex1)
-- [["a","b","c"]]

```

Or with two strongly connected subgraphs:

![](img/graph2.png)

```haskell
ex2 :: [(String, String, [String])]
ex2 = [
    ("a","a",["b"]),
    ("b","b",["c"]),
    ("c","c",["a"]),

    ("d","d",["e"]),
    ("e","e",["f", "e"]),
    ("f","f",["d", "e"])
  ]


ts2 :: [String]
ts2 = topo' (fromList ex2)
-- ["d","e","f","a","b","c"]

sc2 :: [[String]]
sc2 = scc' (fromList ex2)
-- [["d","e","f"],["a","b","c"]]
```

See: [GraphSCC](http://hackage.haskell.org/package/GraphSCC)

Graph Theory
图论
------------

The ``fgl`` library provides a more efficient graph structure and a wide
variety of common graph-theoretic operations. For example calculating the
dominance frontier of a graph shows up quite frequently in control flow analysis
for compiler design.

```haskell
import qualified Data.Graph.Inductive as G

cyc3 :: G.Gr Char String
cyc3 = G.buildGr
       [([("ca",3)],1,'a',[("ab",2)]),
                ([],2,'b',[("bc",3)]),
                ([],3,'c',[])]

-- Loop query
ex1 :: Bool
ex1 = G.hasLoop x

-- Dominators
ex2 :: [(G.Node, [G.Node])]
ex2 = G.dom x 0
```

```haskell
x :: G.Gr Int ()
x = G.insEdges edges gr
  where
  gr = G.insNodes nodes G.empty
  edges = [(0,1,()), (0,2,()), (2,1,()), (2,3,())]
  nodes = zip [0,1 ..] [2,3,4,1]
```

![](img/graphviz.png)

DList
-----

A dlist is a list-like structure that is optimized for O(1) append operations,
internally it uses a Church encoding of the list structure. It is specifically
suited for operations which are append-only and need only access it when
manifesting the entire structure. It is particularly well-suited for use in the
Writer monad.

~~~~ {.haskell include="src/20-data-structures/dlist.hs"}
~~~~

Sequence
序列
--------

The sequence data structure behaves structurally similar to list but is
optimized for append/prepend operations and traversal.

~~~~ {.haskell include="src/20-data-structures/sequence.hs"}
~~~~

Matrices and HBlas
矩阵和
------------------

Just as in C when working with n-dimensional matrices we'll typically overlay
the high-level matrix structure onto an unboxed contiguous block of memory with
index functions which perform the coordinate translations to calculate offsets.
The two most common layouts are:

* Row-major order
* Column-major order

Which are best illustrated.

![](img/matrix.png)

The calculations have a particularly nice implementation in Haskell in terms of
scans over indices.

~~~~ {.haskell include="src/20-data-structures/matrix_index.hs"}
~~~~

Unboxed matrices of this type can also be passed to C or Fortran libraries such
BLAS or LAPACK linear algebra libraries. The ``hblas`` package wraps many of
these routines and forms the low-level wrappers for higher level-libraries that
need access to these foreign routines.

For example the
[dgemm](https://software.intel.com/sites/products/documentation/doclib/mkl_sa/11/tutorials/mkl_mmx_c/GUID-36BFBCE9-EB0A-43B0-ADAF-2B65275726EA.htm)
routine takes two pointers to a sequence of ``double`` values of two matrices of size ``(m × k)`` and ``(k ×
n)`` and performs efficient matrix multiplication writing the resulting data through a pointer to a ``(m ×
n)`` matrix.

~~~~ {.haskell include="src/20-data-structures/hblas.hs"}
~~~~

See: [hblas](https://github.com/wellposed/hblas)

FFI
===

Pure Functions
--------------

Wrapping pure C functions with primitive types is trivial.

~~~~ {.cpp include="src/21-ffi/simple.c"}
~~~~

~~~~ {.haskell include="src/21-ffi/simple_ffi.hs"}
~~~~

Storable Arrays
----------------

There exists a ``Storable`` typeclass that can be used to provide low-level
access to the memory underlying Haskell values. ``Ptr`` objects in Haskell
behave much like C pointers although arithmetic with them is in terms of bytes
only, not the size of the type associated with the pointer ( this differs from
C).

The Prelude defines Storable interfaces for most of the basic types as well as
types in the ``Foreign.C`` library.

```haskell
class Storable a where
  sizeOf :: a -> Int
  alignment :: a -> Int
  peek :: Ptr a -> IO a
  poke :: Ptr a -> a -> IO ()
```

To pass arrays from Haskell to C we can again use Storable Vector and several
unsafe operations to grab a foreign pointer to the underlying data that can be
handed off to C. Once we're in C land, nothing will protect us from doing evil
things to memory!

~~~~ {.cpp include="src/21-ffi/qsort.c"}
~~~~

~~~~ {.haskell include="src/21-ffi/ffi.hs"}
~~~~

The names of foreign functions from a C specific header file can be qualified.

```haskell
foreign import ccall unsafe "stdlib.h malloc"
    malloc :: CSize -> IO (Ptr a)
```

Prepending the function name with a ``&`` allows us to create a reference to the
function pointer itself.

```haskell
foreign import ccall unsafe "stdlib.h &malloc"
    malloc :: FunPtr a
```

Function Pointers
-----------------

Using the above FFI functionality, it's trivial to pass C function pointers into
Haskell, but what about the inverse passing a function pointer to a Haskell
function into C using ``foreign import ccall "wrapper"``.

~~~~ {.cpp include="src/21-ffi/pointer.c"}
~~~~

~~~~ {.haskell include="src/21-ffi/pointer_use.hs"}
~~~~

Will yield the following output:

```bash
Inside of C, now we'll call Haskell
Hello from Haskell, here's a number passed between runtimes:
42
Back inside of C again.
```

Concurrency
===========

The definitive reference on concurrency and parallelism in Haskell is Simon
Marlow's text.  This will section will just gloss over these topics because they
are far better explained in this book.

See: [Parallel and Concurrent Programming in Haskell](http://chimera.labs.oreilly.com/books/1230000000929)

```haskell
forkIO :: IO () -> IO ThreadId
```

Haskell threads are extremely cheap to spawn, using only 1.5KB of RAM depending
on the platform and are much cheaper than a pthread in C. Calling forkIO
10<sup>6</sup> times completes just short of a 1s. Additionally, functional
purity in Haskell also guarantees that a thread can almost always be terminated
even in the middle of a computation without concern.

See: [The Scheduler](https://ghc.haskell.org/trac/ghc/wiki/Commentary/Rts/Scheduler#TheScheduler)

Sparks
------

The most basic "atom" of parallelism in Haskell is a spark. It is a hint to the
GHC runtime that a computation can be evaluated to weak head normal form in
parallel.

```haskell
rpar :: a -> Eval a
rseq :: Strategy a
rdeepseq :: NFData a => Strategy a

runEval :: Eval a -> a
```

``rpar a`` spins off a separate spark that evolutes a to weak head normal form
and places the computation in the spark pool. When the runtime determines that
there is an available CPU to evaluate the computation it will evaluate (
*convert* ) the spark. If the main thread of the program is
the evaluator for the spark, the spark is said to have *fizzled*. Fizzling is
generally bad and indicates that the logic or parallelism strategy is not well
suited to the work that is being evaluated.

The spark pool is also limited ( but user-adjustable ) to a default of 8000 (as
of GHC 7.8.3 ). Sparks that are created beyond that limit are said to
*overflow*.

```haskell
-- Evaluates the arguments to f in parallel before application.
par2 f x y = x `rpar` y `rpar` f x y
```

An argument to ``rseq`` forces the evaluation of a spark before evaluation
continues.

Action          Description
-------------   --------------
``Fizzled``     The resulting value has already been evaluated by the main thread so the spark need not be converted.
``Dud``         The expression has already been evaluated, the computed value is returned and the spark is not converted.
``GC'd``        The spark is added to the spark pool but the result is not referenced, so it is garbage collected.
``Overflowed``  Insufficient space in the spark pool when spawning.


The parallel runtime is necessary to use sparks, and the resulting program must
be compiled with ``-threaded``. Additionally the program itself can be specified
to take runtime options with ``-rtsopts`` such as the number of cores to use.

```haskell
ghc -threaded -rtsopts program.hs
./program +RTS -s N8 -- use 8 cores
```

The runtime can be asked to dump information about the spark evaluation by
passing the ``-s`` flag.

```haskell
$ ./spark +RTS -N4 -s

                                    Tot time (elapsed)  Avg pause  Max pause
  Gen  0         5 colls,     5 par    0.02s    0.01s     0.0017s    0.0048s
  Gen  1         3 colls,     2 par    0.00s    0.00s     0.0004s    0.0007s

  Parallel GC work balance: 1.83% (serial 0%, perfect 100%)

  TASKS: 6 (1 bound, 5 peak workers (5 total), using -N4)

  SPARKS: 20000 (20000 converted, 0 overflowed, 0 dud, 0 GC'd, 0 fizzled)
```

The parallel computations themselves are sequenced in the ``Eval`` monad, whose
evaluation with ``runEval`` is itself a pure computation.

```haskell
example :: (a -> b) -> a -> a -> (b, b)
example f x y = runEval $ do
  a <- rpar $ f x
  b <- rpar $ f y
  rseq a
  rseq b
  return (a, b)
```

Threadscope
-----------

Passing the flag ``-l``  generates the eventlog which can be rendered with the
threadscope library.

```haskell
$ ghc -O2 -threaded -rtsopts -eventlog Example.hs
$ ./program +RTS -N4 -l
$ threadscope Example.eventlog
```

![](img/threadscope.png)

See Simon Marlows's *Parallel and Concurrent Programming in Haskell* for a
detailed guide on interpreting and profiling using Threadscope.

See:

* [Performance profiling with ghc-events-analyze](http://www.well-typed.com/blog/86/)

Strategies
----------

```haskell
type Strategy a = a -> Eval a
using :: a -> Strategy a -> a
```

Sparks themselves form the foundation for higher level parallelism constructs known as ``strategies`` which
adapt spark creation to fit the computation or data structure being evaluated. For instance if we wanted to
evaluate both elements of a tuple in parallel we can create a strategy which uses sparks to evaluate both
sides of the tuple.

~~~~ {.haskell include="src/22-concurrency/strategies.hs"}
~~~~

This pattern occurs so frequently the combinator ``using``  can be used to write it equivalently in
operator-like form that may be more visually appealing to some.

```haskell
using :: a -> Strategy a -> a
x `using` s = runEval (s x)

parallel ::: (Int, Int)
parallel = (fib 30, fib 31) `using` parPair
```

For a less contrived example consider a parallel ``parmap`` which maps a pure function over a list of a values
in parallel.

~~~~ {.haskell include="src/22-concurrency/spark.hs"}
~~~~

The functions above are quite useful, but will break down if evaluation of the arguments needs to be
parallelized beyond simply weak head normal form. For instance if the arguments to ``rpar`` is a nested
constructor we'd like to parallelize the entire section of work in evaluated the expression to normal form
instead of just the outer layer. As such we'd like to generalize our strategies so the the evaluation strategy
for the arguments can be passed as an argument to the strategy.

``Control.Parallel.Strategies`` contains a generalized version of ``rpar`` which embeds additional evaluation
logic inside the ``rpar`` computation in Eval monad.

```haskell
rparWith :: Strategy a -> Strategy a
```

Using the deepseq library we can now construct a Strategy variant of rseq that evaluates to full normal form.

```haskell
rdeepseq :: NFData a => Strategy a
rdeepseq x = rseq (force x)
```

We now can create a "higher order" strategy that takes two strategies and itself yields a a computation which
when evaluated uses the passed strategies in its scheduling.

~~~~ {.haskell include="src/22-concurrency/strategies_param.hs"}
~~~~

These patterns are implemented in the Strategies library along with several other general forms and
combinators for combining strategies to fit many different parallel computations.

```haskell
parTraverse :: Traversable t => Strategy a -> Strategy (t a)
dot :: Strategy a -> Strategy a -> Strategy a
($||) :: (a -> b) -> Strategy a -> a -> b
(.||) :: (b -> c) -> Strategy b -> (a -> b) -> a -> c
```

See:

* [Control.Concurent.Strategies](http://hackage.haskell.org/package/parallel-3.2.0.4/docs/Control-Parallel-Strategies.html)

STM
---

```haskell
atomically :: STM a -> IO a
orElse :: STM a -> STM a -> STM a
retry :: STM a

newTVar :: a -> STM (TVar a)
newTVarIO :: a -> IO (TVar a)
writeTVar :: TVar a -> a -> STM ()
readTVar :: TVar a -> STM a

modifyTVar :: TVar a -> (a -> a) -> STM ()
modifyTVar' :: TVar a -> (a -> a) -> STM ()
```

Software Transactional Memory is a technique for guaranteeing atomicity of
values in parallel computations, such that all contexts view the same data when
read and writes are guaranteed never to result in inconsistent states.

The strength of Haskell's purity guarantees that transactions within STM are
pure and can always be rolled back if a commit fails.

~~~~ {.haskell include="src/22-concurrency/stm.hs"}
~~~~

See: [Beautiful Concurrency](https://www.fpcomplete.com/school/advanced-haskell/beautiful-concurrency)

Monad Par
---------

Using the Par monad we express our computation as a data flow graph which is
scheduled in order of the connections between forked computations which exchange
resulting computations with ``IVar``.

```haskell
new :: Par (IVar a)
put :: NFData a => IVar a -> a -> Par ()
get :: IVar a -> Par a
fork :: Par () -> Par ()
spawn :: NFData a => Par a -> Par (IVar a)
```

![](img/par.png)

~~~~ {.haskell include="src/22-concurrency/par.hs"}
~~~~

async
-----

Async is a higher level set of functions that work on top of Control.Concurrent
and STM.

```haskell
async :: IO a -> IO (Async a)
wait :: Async a -> IO a
cancel :: Async a -> IO ()
concurrently :: IO a -> IO b -> IO (a, b)
race :: IO a -> IO b -> IO (Either a b)
```

~~~~ {.haskell include="src/22-concurrency/async.hs"}
~~~~

Graphics
========

Diagrams
--------

Diagrams is a a parser combinator library for generating vector images to SVG and a variety of other formats.

~~~~ {.haskell include="src/23-graphics/diagrams.hs"}
~~~~

```bash
$ runhaskell diagram1.hs -w 256 -h 256 -o diagram1.svg
```

![](img/diagram1.png)

See: [Diagrams Quick Start Tutorial](http://projects.haskell.org/diagrams/doc/quickstart.html)

Gloss
-----

解析器
=======

Parsec
------

在Haskell里进行语法解析，人们常常会用到一类库，称作*解析器组合子（Parser Combinators）*。它可以让我们使用代码来生成解析器，而这些解析器与解析语法本身非常相似！
              组合子
-----------   ------------
``<|>``       称为“选择操作符”，先匹配第一个参数，匹配不到再去匹配第二个。可以链式使用来生成多个匹配选项。
``many``      使用给定模式消耗任意数量的模式，并返回由它们组成的列表。
``many1``     和many相似，但至少要有一次成功匹配。
``optional``  选择性匹配，返回一个Maybe值。
``try``       称为“回溯操作符”，若匹配失败，不会消耗任何输入，使用下一个模式重新匹配。

Parsec有单子和应用式函子两种使用风格。

```haskell
parseM :: Parser Expr
parseM = do
  a <- identifier
  char '+'
  b <- identifier
  return $ Add a b
```

若写成应用式函子风格，则使用应用式组合子，如下：

```haskell
-- | 顺序应用。
(<*>) :: f (a -> b) -> f a -> f b

-- | 顺序应用，抛弃第一个值。
(*>) :: f a -> f b -> f b
(*>) = liftA2 (const id)

-- | 顺序应用，抛弃第二个值。
(<*) :: f a -> f b -> f a
(<*) = liftA2 const
```

```haskell
parseA :: Parser Expr
parseA = Add <$> identifier <* char '+' <*> identifier
```

现在我们要解析一个简单的λ表达式，可以把这些组合子合并，并使用``parse``函数来得到最终的解析器。

~~~~ {.haskell include="src/24-parsing/simple_parser.hs"}
~~~~

自定义词法分析器(Custom Lexer)
------------

前面的例子中，输入流并不需要先通过词法分析器，因为每个词位会匹配到字符流中的一个连续的字符集合。如果我们想用一组有意义的符号集来扩展解析器，可以使用Parsec提供的一套函数来定义词法解析器，并用解析器组合子来整合这些词法解析器。最简单的例子是构建在内置Parsec语言上的定义，这些定义定义了一套最常见的词法组合。

```haskell
haskellDef   :: LanguageDef st
emptyDef     :: LanguageDef st
haskellStyle :: LanguageDef st
javaStyle    :: LanguageDef st
```

如下构建在空语言语法上的例子：

~~~~ {.haskell include="src/24-parsing/lexer.hs"}
~~~~

See: [Text.ParserCombinators.Parsec.Language](http://hackage.haskell.org/package/parsec-3.1.5/docs/Text-ParserCombinators-Parsec-Language.html)

简单解析
--------------

把词法解析器和分析器放在一起，可以让我们写出解析lambda演算句法时鲁棒性更强的分析器。

~~~~ {.haskell include="src/24-parsing/parser.hs"}
~~~~

试试看下面的例子：

```bash
λ: runhaskell simpleparser.hs
1+2
Op Add (Num 1) (Num 2)

\i -> \x -> x
Lam "i" (Lam "x" (Var "x"))

\s -> \f -> \g -> \x -> f x (g x)
Lam "s" (Lam "f" (Lam "g" (Lam "x" (App (App (Var "f") (Var "x")) (App (Var "g") (Var "x"))))))
```

状态解析
----------------
解析器的一个更复杂的应用是，使用有内部状态的解析器，例如增加在解析的同时定义的操作符，动态添加到 ``expressionParser`` 表上。 （upon definition.）

~~~~ {.haskell include="src/24-parsing/parsec_operators.hs"}
~~~~

试试如下代码：

```haskell
infixl 3 ($);
infixr 4 (#);

infix 4 (.);

prefix 10 (-);
postfix 10 (!);

let z = y in a $ a $ (-a)!;
let z = y in a # a # a $ b; let z = y in a # a # a # b;
```

一般解析
---------------

之前我们为整齐打印定义了一般操作，这一操作回避了是否能在泛型上写一个解析器这个问题，问题的答案通常是能，只要在特定词位和产品类型之间有直接的匹配。考虑最简单的一种情况，我们仅仅用泛型机器读取构造函数的名字，然后构建他们的Parsec解析器关系。

~~~~ {.haskell include="src/24-parsing/generics.hs"}
~~~~

```haskell
λ: parseTest parseMusician "Bach"
Bach

λ: parseTest parseScientist "Feynman"
Feynman
```

Attoparsec
----------

Attoparsec 是一种像 Parsec 一样的解析器组合子， 但是Attoparsec比Parsec更适合大文本和二进制文件的批量解析，而不是把语言语法解析到ASTs。如果写的合适，Attoparsec会[极其有效](http://www.serpentine.com/blog/2014/05/31/attoparsec/)。 

Parsec 和 Attoparsec 一个值得注意的区别是，回溯操作符(``try``)在Attoparsec中并不存在（not present），它是映射到Attoparsec的不同潜在解析模型上的。

对于一个小的匿名微积分函数语言，我们用 Attoparsec 和用 Parsec 是一样的：

~~~~ {.haskell include="src/24-parsing/attoparsec_lang.hs"}
~~~~

比如，用下面的简单匿名函数表达式试试上面的解析：

~~~~ {.ocaml include="src/24-parsing/simple.ml"}
~~~~

Attoparsec 也能非常好地适应二进制和网络协议风格解析，这个结论得自于分布式网络协议统一性的实现:

~~~~ {.haskell include="src/24-parsing/attoparsec.hs"}
~~~~

See: [Text Parsing Tutorial](https://www.fpcomplete.com/school/starting-with-haskell/libraries-and-frameworks/text-manipulation/attoparsec)

Streaming
=========

Lazy IO
-------

The problem with using the usual monadic approach to processing data accumulated through IO is that the
Prelude tools require us to manifest large amounts of data in memory all at once before we can even begin
computation.

```haskell
mapM :: Monad m => (a -> m b) -> [a] -> m [b]
sequence :: Monad m => [m a] -> m [a]
```

Reading from the file creates a thunk for the string that forced will then read the file. The problem is then
that this method ties the ordering of IO effects to evaluation order which is difficult to reason about in the
large.

Consider that normally the monad laws ( in the absence of `seq` ) guarantee that these computations should be
identical. But using lazy IO we can construct a degenerate case.

~~~~ {.haskell include="src/25-streaming/lazyio.hs"}
~~~~

So what we need is a system to guarantee deterministic resource handling with constant memory usage. To that
end both the Conduits and Pipes libraries solved this problem using different ( though largely equivalent )
approaches.

Pipes
-----

```haskell
await :: Monad m => Pipe a y m a
yield :: Monad m => a -> Pipe x a m ()

(>->) :: Monad m
      => Pipe a b m r
      -> Pipe b c m r
      -> Pipe a c m r

runEffect :: Monad m => Effect m r -> m r
toListM :: Monad m => Producer a m () -> m [a]
```

Pipes is a stream processing library with a strong emphasis on the static semantics of composition. The
simplest usage is to connect "pipe" functions with a ``(>->)`` composition operator, where each component can
``await`` and ``yield`` to push and pull values along the stream.

~~~~ {.haskell include="src/25-streaming/pipes.hs"}
~~~~

For example we could construct a "FizzBuzz" pipe.


~~~~ {.haskell include="src/25-streaming/pipes_io.hs"}
~~~~

To continue with the degenerate case we constructed with Lazy IO, consider than we can now compose and sequence
deterministic actions over files without having to worry about effect order.

~~~~ {.haskell include="src/25-streaming/pipes_file.hs"}
~~~~

This is simple a sampling of the functionality of pipes. The documentation for
pipes is extensive and great deal of care has been taken make the library
extremely thorough. ``pipes`` is a shining example of an accessible yet category
theoretic driven design.

See: [Pipes Tutorial](http://hackage.haskell.org/package/pipes-4.1.0/docs/Pipes-Tutorial.html)

Safe Pipes
----------

```haskell
bracket :: MonadSafe m => Base m a -> (a -> Base m b) -> (a -> m c) -> m c
```

As a motivating example, ZeroMQ is a network messaging library that abstracts over traditional Unix sockets to
a variety of network topologies.  Most notably it isn't designed to guarantee any sort of transactional
guarantees for delivery or recovery in case of errors so it's necessary to design a layer on top of it to
provide the desired behavior at the application layer.

In Haskell we'd like to guarantee that if we're polling on a socket we get messages delivered in a timely
fashion or consider the resource in an error state and recover from it. Using ``pipes-safe`` we can manage the
life cycle of lazy IO resources and can safely handle failures, resource termination and finalization
gracefully. In other languages this kind of logic would be smeared across several places, or put in some
global context and prone to introduce errors and subtle race conditions. Using pipes we instead get a nice
tight abstraction designed exactly to fit this kind of use case.

For instance now we can bracket the ZeroMQ socket creation and finalization within the ``SafeT`` monad
transformer which guarantees that after successful message delivery we execute the pipes function as expected,
or on failure we halt the execution and finalize the socket.

~~~~ {.haskell include="src/25-streaming/pipes_safe.hs"}
~~~~

Conduits
--------

```haskell
await :: Monad m => ConduitM i o m (Maybe i)
yield :: Monad m => o -> ConduitM i o m ()
($$) :: Monad m => Source m a -> Sink a m b -> m b
(=$) :: Monad m => Conduit a m b -> Sink b m c -> Sink a m c

type Sink i = ConduitM i Void
type Source m o = ConduitM () o m ()
type Conduit i m o = ConduitM i o m ()
```

Conduits are conceptually similar though philosophically different approach to the same problem of constant
space deterministic resource handling for IO resources.

The first initial difference is that await function now returns a ``Maybe`` which allows different handling of
termination. The composition operators are also split into a connecting operator (``$$``) and a fusing
operator (``=$``) for combining Sources and Sink and a Conduit and a Sink respectively.

~~~~ {.haskell include="src/25-streaming/conduit.hs"}
~~~~

See: [Conduit Overview](https://www.fpcomplete.com/user/snoyberg/library-documentation/conduit-overview)

Data Formats
=============

JSON
----

Aeson is library for efficient parsing and generating JSON.

```haskell
decode :: FromJSON a => ByteString -> Maybe a
encode :: ToJSON a => a -> ByteString
eitherDecode :: FromJSON a => ByteString -> Either String a

fromJSON :: FromJSON a => Value -> Result a
toJSON :: ToJSON a => a -> Value
```

We'll work with this contrived example:

~~~~ {.json include="src/26-data-formats/example.json"}
~~~~

Aeson uses several high performance data structures (Vector, Text, HashMap) by default instead of the naive
versions so typically using Aeson will require that us import them and use ``OverloadedStrings`` when
indexing into objects.

```haskell
type Object = HashMap Text Value

type Array = Vector Value

-- | A JSON value represented as a Haskell value.
data Value = Object !Object
           | Array !Array
           | String !Text
           | Number !Scientific
           | Bool !Bool
           | Null
```

See: [Aeson Documentation](http://hackage.haskell.org/package/aeson)

**Unstructured**

In dynamic scripting languages it's common to parse amorphous blobs of JSON without any a priori structure and
then handle validation problems by throwing exceptions while traversing it. We can do the same using Aeson and
the Maybe monad.

~~~~ {.haskell include="src/26-data-formats/aeson_unstructured.hs"}
~~~~

**Structured**

This isn't ideal since we've just smeared all the validation logic across our traversal logic instead of
separating concerns and handling validation in separate logic. We'd like to describe the structure before-hand
and the invalid case separately. Using Generic also allows Haskell to automatically write the serializer and
deserializer between our datatype and the JSON string based on the names of record field names.

~~~~ {.haskell include="src/26-data-formats/aeson_structured.hs"}
~~~~

Now we get our validated JSON wrapped up into a nicely typed Haskell ADT.

```haskell
Data
  { id = 1
  , name = "A green door"
  , price = 12
  , tags = [ "home" , "green" ]
  , refs = Refs { a = "red" , b = "blue" }
  }
```

The functions ``fromJSON`` and ``toJSON`` can be used to convert between this sum type and regular Haskell
types with.

```haskell
data Result a = Error String | Success a
```

```haskell
λ: fromJSON (Bool True) :: Result Bool
Success True

λ: fromJSON (Bool True) :: Result Double
Error "when expecting a Double, encountered Boolean instead"
```

CSV
---

Cassava is an efficient CSV parser library. We'll work with this tiny snippet from the iris dataset:

~~~~ {.perl include="src/26-data-formats/iris.csv"}
~~~~

**Unstructured**

Just like with Aeson if we really want to work with unstructured data the library accommodates this.

~~~~ {.haskell include="src/26-data-formats/cassava_unstructured.hs"}
~~~~

We see we get the nested set of stringy vectors:


```haskell
[ [ "sepal_length"
  , "sepal_width"
  , "petal_length"
  , "petal_width"
  , "plant_class"
  ]
, [ "5.1" , "3.5" , "1.4" , "0.2" , "Iris-setosa" ]
, [ "5.0" , "2.0" , "3.5" , "1.0" , "Iris-versicolor" ]
, [ "6.3" , "3.3" , "6.0" , "2.5" , "Iris-virginica" ]
]
```

**Structured**

Just like with Aeson we can use Generic to automatically write the deserializer between our CSV data and our
custom datatype.

~~~~ {.haskell include="src/26-data-formats/cassava_structured.hs"}
~~~~

And again we get a nice typed ADT as a result.

```haskell
[ Plant
    { sepal_length = 5.1
    , sepal_width = 3.5
    , petal_length = 1.4
    , petal_width = 0.2
    , plant_class = "Iris-setosa"
    }
, Plant
    { sepal_length = 5.0
    , sepal_width = 2.0
    , petal_length = 3.5
    , petal_width = 1.0
    , plant_class = "Iris-versicolor"
    }
, Plant
    { sepal_length = 6.3
    , sepal_width = 3.3
    , petal_length = 6.0
    , petal_width = 2.5
    , plant_class = "Iris-virginica"
    }
]
```

Network & Web Programming
=========================

HTTP
----

Haskell has a variety of HTTP request and processing libraries.

~~~~ {.haskell include="src/27-web/http.hs"}
~~~~

Warp
----

Warp is a particularly efficient web server, it's the backed request engine
behind several of popular Haskell web frameworks. The internals have been finely
tuned to utilize Haskell's concurrent runtime and is capable of handling a great
deal of concurrent requests.

~~~~ {.haskell include="src/27-web/warp.hs"}
~~~~

See: [Warp](http://aosabook.org/en/posa/warp.html)

Scotty
------

Continuing with our trek through web libraries, Scotty is a web microframework
similar in principle to Flask in Python or Sinatra in Ruby.

~~~~ {.haskell include="src/27-web/scotty.hs"}
~~~~

Of importance to note is the Blaze library used here overloads do-notation but
is not itself a proper monad so the various laws and invariants that normally
apply for monads may break down or fail with error terms.

See: [Making a Website with Haskell](http://adit.io/posts/2013-04-15-making-a-website-with-haskell.html)

Databases
=========

Acid State
----------

Acid-state allows us to build a "database on demand" for arbitrary Haskell datatypes that guarantees atomic
transactions. For example, we can build a simple key-value store wrapped around the Map type.

~~~~ {.haskell include="src/28-databases/acid.hs"}
~~~~

GHC
===

Block Diagram
-------------

The flow of code through GHC is a process of translation between several
intermediate languages and optimizations and transformations thereof. A common
pattern for many of these AST types is they are parametrized over a binder type
and at various stages the binders will be transformed, for example the Renamer
pass effectively translates the ``HsSyn`` datatype from a AST parametrized over
literal strings as the user enters into a ``HsSyn`` parameterized over qualified
names that includes modules and package names into a higher level Name type.

![](img/ghc.png)

* **Parser/Frontend**: An enormous AST translated from human syntax that makes
  explicit possible all expressible syntax ( declarations, do-notation, where
  clauses, syntax extensions, template haskell, ... ). This is unfiltered
  Haskell and it is *enormous*.
* **Renamer** takes syntax from the frontend and transforms all names to be
  qualified (``base:Prelude.map`` instead of ``map``) and any shadowed names in
  lambda binders transformed into unique names.
* **Typechecker** is a large pass that serves two purposes, first is the core type
  bidirectional inference engine where most of the work happens and the
  translation between the frontend ``Core`` syntax.
* **Desugarer** translates several higher level syntactic constructors
    - ``where`` statements are turned into (possibly recursive) nested ``let``
      statements.
    - Nested pattern matches are expanded out into splitting trees of case
      statements.
    - do-notation is expanded into explicit bind statements.
    - Lots of others.
* **Simplifier** transforms many Core constructs into forms that are more
  adaptable to compilation. For example let statements will be floated or
  raised, pattern matches will simplified, inner loops will be pulled out and
  transformed into more optimal forms. Non-intuitively the resulting may
  actually be much more complex (for humans) after going through the simplifier!
* **Stg** pass translates the resulting Core into STG (Spineless Tagless
   G-Machine) which effectively makes all laziness explicit and encodes the
   thunks and update frames that will be handled during evaluation.
* **Codegen/Cmm** pass will then translate STG into Cmm (flavoured C--) a simple
  imperative language that manifests the low-level implementation details of
  runtime types. The runtime closure types and stack frames are made explicit
  and low-level information about the data and code (arity, updatability, free
  variables, pointer layout) made manifest in the info tables present on most
  constructs.
* **Native Code** The final pass will than translate the resulting code into
  either LLVM or Assembly via either through GHC's home built native code
  generator (NCG) or the LLVM backend.


Information for about each pass can dumped out via a rather large collection of
flags. The GHC internals are very accessible although some passes are somewhat
easier to understand than others. Most of the time ``-ddump-simpl`` and
``-ddump-stg`` are sufficient to get an understanding of how the code will
compile, unless of course you're dealing with very specialized optimizations or
hacking on GHC itself.

Flag                   Action
--------------         ------------
``-ddump-parsed``      Frontend AST.
``-ddump-rn``          Output of the rename pass.
``-ddump-tc``          Output of the typechecker.
``-ddump-splices``     Output of TemplateHaskell splices.
``-ddump-types``       Typed AST representation.
``-ddump-deriv``       Output of deriving instances.
``-ddump-ds``          Output of the desugar pass.
``-ddump-spec``        Output of specialisation pass.
``-ddump-rules``       Output of applying rewrite rules.
``-ddump-vect``        Output results of vectorize pass.
``-ddump-simpl``       Ouptut of the SimplCore pass.
``-ddump-inlinings``   Output of the inliner.
``-ddump-cse``         Output of the common subexpression elimination pass.
``-ddump-prep``        The CorePrep pass.
``-ddump-stg``         The resulting STG.
``-ddump-cmm``         The resulting Cmm.
``-ddump-opt-cmm``     The resulting Cmm optimization pass.
``-ddump-asm``         The final assembly generated.
``-ddump-llvm``        The final LLVM IR generated.

Core
----

Core is the explicitly typed System-F family syntax through that all Haskell
constructs can be expressed in.

To inspect the core from GHCi we can invoke it using the following flags and the
following shell alias. We have explicitly disable the printing of certain
metadata and longform names to make the representation easier to read.

```bash
alias ghci-core="ghci -ddump-simpl -dsuppress-idinfo \
-dsuppress-coercions -dsuppress-type-applications \
-dsuppress-uniques -dsuppress-module-prefixes"
```

At the interactive prompt we can then explore the core representation interactively:

```bash
$ ghci-core
λ: let f x = x + 2 ; f :: Int -> Int

==================== Simplified expression ====================
returnIO
  (: ((\ (x :: Int) -> + $fNumInt x (I# 2)) `cast` ...) ([]))

λ: let f x = (x, x)

==================== Simplified expression ====================
returnIO (: ((\ (@ t) (x :: t) -> (x, x)) `cast` ...) ([]))
```

[ghc-core](http://hackage.haskell.org/package/ghc-core) is also very useful for
looking at GHC's compilation artifacts.

```bash
$ ghc-core --no-cast --no-asm
```

Alternatively the major stages of the compiler ( parse tree, core, stg, cmm, asm
) can be manually outputted and inspected by passing several flags to the
compiler:

```bash
$ ghc -ddump-to-file -ddump-parsed -ddump-simpl -ddump-stg -ddump-cmm -ddump-asm
```

**Reading Core**

Core from GHC is roughly human readable, but it's helpful to look at simple
human written examples to get the hang of what's going on.

```haskell
id :: a -> a
id x = x
```

```haskell
id :: forall a. a -> a
id = \ (@ a) (x :: a) -> x

idInt :: GHC.Types.Int -> GHC.Types.Int
idInt = id @ GHC.Types.Int
```

```haskell
compose :: (b -> c) -> (a -> b) -> a -> c
compose f g x = f (g x)
```

```haskell
compose :: forall b c a. (b -> c) -> (a -> b) -> a -> c
compose = \ (@ b) (@ c) (@ a) (f1 :: b -> c) (g :: a -> b) (x1 :: a) -> f1 (g x1)
```

```haskell
map :: (a -> b) -> [a] -> [b]
map f []     = []
map f (x:xs) = f x : map f xs
```

```haskell
map :: forall a b. (a -> b) -> [a] -> [b]
map =
  \ (@ a) (@ b) (f :: a -> b) (xs :: [a]) ->
    case xs of _ {
      []     -> [] @ b;
      : y ys -> : @ b (f y) (map @ a @ b f ys)
    }
```

Machine generated names are created for a lot of transformation of Core.
Generally they consist of a prefix and unique identifier. The prefix is often
pass specific ( i.e. ``ds`` for desugar generated name s) and sometimes specific
names are generated for specific automatically generated code. A non exhaustive
cheat sheet is given below for deciphering what a name is and what it might
stand for:

Prefix       Description
----------   ---------------------------------
``$f...``    Dict-fun identifiers (from inst decls)
``$dmop``    Default method for 'op'
``$wf``      Worker for function 'f'
``$sf``      Specialised version of f
``$gdm``     Generated class method
``$d``       Dictionary names
``$s``       Specialized function name
``$f``       Foreign export
``$pnC``     n'th superclass selector for class C
``T:C``      Tycon for dictionary for class C
``D:C``      Data constructor for dictionary for class C
``NTCo:T``   Coercion for newtype T to its underlying runtime representation

Of important note is that the Λ and λ for type-level and value-level lambda
abstraction are represented by the same symbol (``\``) in core, which is a
simplifying detail of the GHC's implementation but a source of some confusion
when starting.

```haskell
-- System-F Notation
Λ b c a. λ (f1 : b -> c) (g : a -> b) (x1 : a). f1 (g x1)

-- Haskell Core
\ (@ b) (@ c) (@ a) (f1 :: b -> c) (g :: a -> b) (x1 :: a) -> f1 (g x1)
```

The ``seq`` function has an intuitive implementation in the Core language.

```haskell
x `seq` y
```

```haskell
case x of _ {
  __DEFAULT -> y
}
```

One particularly notable case of the Core desugaring process is that pattern matching on overloaded numbers
implicitly translates into equality test (i.e. ``Eq``).

```haskell
f 0 = 1
f 1 = 2
f 2 = 3
f 3 = 4
f 4 = 5
f _ = 0


f :: forall a b. (Eq a, Num a, Num b) => a -> b
f =
  \ (@ a)
    (@ b)
    ($dEq :: Eq a)
    ($dNum :: Num a)
    ($dNum1 :: Num b)
    (ds :: a) ->
    case == $dEq ds (fromInteger $dNum (__integer 0)) of _ {
      False ->
        case == $dEq ds (fromInteger $dNum (__integer 1)) of _ {
          False ->
            case == $dEq ds (fromInteger $dNum (__integer 2)) of _ {
              False ->
                case == $dEq ds (fromInteger $dNum (__integer 3)) of _ {
                  False ->
                    case == $dEq ds (fromInteger $dNum (__integer 4)) of _ {
                      False -> fromInteger $dNum1 (__integer 0);
                      True -> fromInteger $dNum1 (__integer 5)
                    };
                  True -> fromInteger $dNum1 (__integer 4)
                };
              True -> fromInteger $dNum1 (__integer 3)
            };
          True -> fromInteger $dNum1 (__integer 2)
        };
      True -> fromInteger $dNum1 (__integer 1)
    }
```

Of course, adding a concrete type signature changes the desugar just matching on the unboxed values.

```haskell
f :: Int -> Int
f =
  \ (ds :: Int) ->
    case ds of _ { I# ds1 ->
    case ds1 of _ {
      __DEFAULT -> I# 0;
      0 -> I# 1;
      1 -> I# 2;
      2 -> I# 3;
      3 -> I# 4;
      4 -> I# 5
    }
    }
```

See:

* [Core Spec](https://github.com/ghc/ghc/blob/master/docs/core-spec/core-spec.pdf)
* [Core By Example](http://alpmestan.com/2013/06/27/ghc-core-by-example-episode-1/)
* [CoreSynType](https://ghc.haskell.org/trac/ghc/wiki/Commentary/Compiler/CoreSynType)

Inliner
-------

```haskell
infixr 0  $

($):: (a -> b) -> a -> b
f $ x =  f x
```

Having to enter a secondary closure every time we used ``($)`` would introduce
an enormous overhead. Fortunately GHC has a pass to eliminate small functions
like this by simply replacing the function call with the body of its definition
at appropriate call-sites. There compiler contains a variety heuristics for
determining when this kind of substitution is appropriate and the potential
costs involved.

In addition to the automatic inliner, manual pragmas are provided for more
granular control over inlining.  It's important to note that naive inlining
quite often results in significantly worse performance and longer compilation
times.

```haskell
{-# INLINE func #-}
{-# INLINABLE func #-}
{-# NOINLINE func #-}
```

For example the contrived case where we apply a binary function to two
arguments. The function body is small and instead of entering another closure
just to apply the given function, we could in fact just inline the function
application at the call site.

```haskell
{-# INLINE foo #-}
{-# NOINLINE bar #-}

foo :: (a -> b -> c) -> a -> b -> c
foo f x y = f x y

bar :: (a -> b -> c) -> a -> b -> c
bar f x y = f x y

test1 :: Int
test1 = foo (+) 10 20

test2 :: Int
test2 = bar (+) 20 30
```

Looking at the core, we can see that in ``test2`` the function has indeed been
expanded at the call site and simply performs the addition there instead of
another indirection.

```haskell
test1 :: Int
test1 =
  let {
    f :: Int -> Int -> Int
    f = + $fNumInt } in
  let {
    x :: Int
    x = I# 10 } in
  let {
    y :: Int
    y = I# 20 } in
  f x y

test2 :: Int
test2 = bar (+ $fNumInt) (I# 20) (I# 30)
```

Cases marked with ``NOINLINE`` generally indicate that the logic in the function
is using something like ``unsafePerformIO`` or some other unholy function. In
these cases naive inlining might duplicate effects at multiple call-sites
throughout the program which would be undesirable.

See:

* [Secrets of the Glasgow Haskell Compiler inliner](https://research.microsoft.com/en-us/um/people/simonpj/Papers/inlining/inline.pdf)

Dictionaries
------------

The Haskell language defines the notion of Typeclasses but is agnostic to how
they are implemented in a Haskell compiler. GHC's particular implementation uses
a pass called the *dictionary passing translation* part of the elaboration phase
of the typechecker which translates Core functions with typeclass constraints
into implicit parameters of which record-like structures containing the function
implementations are passed.

```haskell
class Num a where
  (+) :: a -> a -> a
  (*) :: a -> a -> a
  negate :: a -> a
```

This class can be thought as the implementation equivalent to the following
parameterized record of functions.

```haskell
data DNum a = DNum (a -> a -> a) (a -> a -> a) (a -> a)

add (DNum a m n) = a
mul (DNum a m n) = m
neg (DNum a m n) = n

numDInt :: DNum Int
numDInt = DNum plusInt timesInt negateInt

numDFloat :: DNum Float
numDFloat = DNum plusFloat timesFloat negateFloat
```

```haskell
+ :: forall a. Num a => a -> a -> a
+ = \ (@ a) (tpl :: Num a) ->
  case tpl of _ { D:Num tpl _ _ -> tpl }

* :: forall a. Num a => a -> a -> a
* = \ (@ a) (tpl :: Num a) ->
  case tpl of _ { D:Num _ tpl _ -> tpl }

negate :: forall a. Num a => a -> a
negate = \ (@ a) (tpl :: Num a) ->
  case tpl of _ { D:Num _ _ tpl -> tpl }
```

``Num`` and ``Ord`` have simple translation but for monads with existential type
variables in their signatures, the only way to represent the equivalent
dictionary is using ``RankNTypes``. In addition a typeclass may also include
superclasses which would be included in the typeclass dictionary and
parameterized over the same arguments and an implicit superclass constructor
function is created to pull out functions from the superclass for the current
monad.

```haskell
data DMonad m = DMonad
  { bind   :: forall a b. m a -> (a -> m b) -> m b
  , return :: forall a. a -> m a
  }
```

```haskell
class (Functor t, Foldable t) => Traversable t where
    traverse :: Applicative f => (a -> f b) -> t a -> f (t b)
    traverse f = sequenceA . fmap f
```

```haskell
data DTraversable t = DTraversable
  { dFunctorTraversable :: DFunctor t  -- superclass dictionary
  , dFoldableTraversable :: DFoldable t -- superclass dictionary
  , traverse :: forall a. Applicative f => (a -> f b) -> t a -> f (t b)
  }
```

Indeed this is not that far from how GHC actually implements typeclasses. It
elaborates into projection functions and data constructors nearly identical to
this, and are implicitly threaded for every overloaded identifier.

Specialization
--------------

Overloading in Haskell is normally not entirely free by default, although with
an optimization called specialization it can be made to have zero cost at
specific points in the code where performance is crucial. This is not enabled by
default by virtue of the fact that GHC is not a whole-program optimizing
compiler and most optimizations ( not all ) stop at module boundaries.

GHC's method of implementing typeclasses means that explicit dictionaries are
threaded around implicitly throughout the call sites. This is normally the most
natural way to implement this functionality since it preserves separate
compilation. A function can be compiled independently of where it is declared,
not recompiled at every point in the program where it's called. The dictionary
passing allows the caller to thread the implementation logic for the types to
the call-site where it can then be used throughout the body of the function.

Of course this means that in order to get at a specific typeclass function we
need to project ( possibly multiple times ) into the dictionary structure to
pluck out the function reference. The runtime makes this very cheap but not
entirely free.

Many C++ compilers or whole program optimizing compilers do the opposite
however, they explicitly specialize each and every function at the call site
replacing the overloaded function with its type-specific implementation. We can
selectively enable this kind of behavior using class specialization.

~~~~ {.haskell include="src/29-ghc/specialize.hs"}
~~~~

**Non-specialized**

```haskell
f :: forall a. Floating a => a -> a -> a
f =
  \ (@ a) ($dFloating :: Floating a) (eta :: a) (eta1 :: a) ->
    let {
      a :: Fractional a
      a = $p1Floating @ a $dFloating } in
    let {
      $dNum :: Num a
      $dNum = $p1Fractional @ a a } in
    * @ a
      $dNum
      (exp @ a $dFloating (+ @ a $dNum eta eta1))
      (exp @ a $dFloating (+ @ a $dNum eta eta1))
```

In the specialized version the typeclass operations placed directly at the call
site and are simply unboxed arithmetic. This will map to a tight set of
sequential CPU instructions and is very likely the same code generated by C.

```haskell
spec :: Double
spec = D# (*## (expDouble# 30.0) (expDouble# 30.0))
```

The non-specialized version has to project into the typeclass dictionary
(``$fFloatingFloat``) 6 times and likely go through around 25 branches to
perform the same operation.

```haskell
nonspec :: Float
nonspec =
  f @ Float $fFloatingFloat (F# (__float 10.0)) (F# (__float 20.0))
```

For a tight loop over numeric types specializing at the call site can result in
orders of magnitude performance increase. Although the cost in compile-time can
often be non-trivial and when used function used at many call-sites this can
slow GHC's simplifier pass to a crawl.

The best advice is profile and look for large uses of dictionary projection in
tight loops and then specialize and inline in these places.

Using the ``SPECIALISE INLINE`` pragma can unintentionally cause GHC to diverge
if applied over a recursive function, it will try to specialize itself
infinitely.

Static Compilation
------------------

On Linux, Haskell programs can be compiled into a standalone statically linked
binary that includes the runtime statically linked into it.

```bash
$ ghc -O2 --make -static -optc-static -optl-static -optl-pthread Example.hs
$ file Example
Example: ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), statically linked, for GNU/Linux 2.6.32, not stripped
$ ldd Example
        not a dynamic executable

```

In addition the file size of the resulting binary can be reduced by stripping
unneeded symbols.

```bash
$ strip Example
```

Unboxed Types
--------------

The usual numerics types in Haskell can be considered to be a regular algebraic
datatype with special constructor arguments for their underlying unboxed values.
Normally unboxed types and explicit unboxing are not used in normal code, they
are an implementation detail of the compiler and many optimizations exist to do
the unboxing in a way that is guaranteed to be safe and preserve the high level
semantics of Haskell. Nevertheless it is somewhat enlightening to understand how
the types are implemented.

```haskell
data Int = I# Int#

data Integer
  = S# Int#              -- Small integers
  | J# Int# ByteArray#   -- Large GMP integers

data Float = F# Float#
```

```haskell
λ: :set -XMagicHash
λ: :m +GHC.Types
λ: :m +GHC.Prim

λ: :type 3#
3# :: GHC.Prim.Int#

λ: :type 3##
3## :: GHC.Prim.Word#

λ: :type 3.14#
3.14# :: GHC.Prim.Float#

λ: :type 3.14##
3.14## :: GHC.Prim.Double#

λ: :type 'c'#
'c'# :: GHC.Prim.Char#

λ: :type "Haskell"#
"Haskell"# :: Addr#

λ: :i Int
data Int = I# Int#      -- Defined in GHC.Types

λ: :k Int#
Int# :: #
```

An unboxed type with kind ``#`` and will never unify a type variable of kind
``*``. Intuitively a type with kind ``*`` indicates a type with a uniform
runtime representation that can be used polymorphically.

- *Lifted* - Can contain a bottom term, represented by a pointer. ( ``Int``, ``Any``, ``(,)`` )
- *Unlited* - Cannot contain a bottom term, represented by a value on the stack. ( ``Int#``, ``(#, #)`` )

~~~~ {.haskell include="src/29-ghc/prim.hs"}
~~~~

The function for integer arithmetic used in the ``Num`` typeclass for ``Int`` is
just pattern matching on this type to reveal the underlying unboxed value,
performing the builtin arithmetic and then performing the packing up into
``Int`` again.

```haskell
plusInt :: Int -> Int -> Int
(I# x) `plusInt` (I# y) = I# (x +# y)
```

Where ``(+#)`` is a low level function built into GHC that maps to intrinsic
integer addition instruction for the CPU.

```haskell
plusInt :: Int -> Int -> Int
plusInt a b = case a of {
    (I# a_) -> case b of {
      (I# b_) -> I# (+# a_ b_);
    };
};
```

Runtime values in Haskell are by default represented uniformly by a boxed
``StgClosure*`` struct which itself contains several payload values, which can
themselves either be pointers to other boxed values or to unboxed literal values
that fit within the system word size and are stored directly within the closure
in memory. The layout of the box is described by a bitmap in the header for the
closure which describes which values in the payload are either pointers or
non-pointers.

The ``unpackClosure#`` primop can be used to extract this information at runtime
by reading off the bitmap on the closure.

~~~~ {.haskell include="src/29-ghc/closure_size.hs"}
~~~~

For example the datatype with the ``UNPACK`` pragma contains 1 non-pointer and 0
pointers.

```haskell
data A = A {-# UNPACK #-} !Int
Size {ptrs = 0, nptrs = 1, size = 16}
```

While the default packed datatype contains 1 pointer and 0 non-pointers.

```haskell
data B = B Int
Size {ptrs = 1, nptrs = 0, size = 9}
```

The closure representation for data constructors are also "tagged" at the
runtime with the tag of the specific constructor. This is however not a runtime
type tag since there is no way to recover the type from the tag as all
constructor simply use the sequence (0, 1, 2, ...). The tag is used to
discriminate cases in pattern matching. The builtin ``dataToTag#`` can  be used
to pluck off the tag for an arbitrary datatype. This is used in some cases when
desugaring pattern matches.

```haskell
dataToTag# :: a -> Int#
```

For example:

```haskell
-- data Bool = False | True
-- False ~ 0
-- True  ~ 1

a :: (Int, Int)
a = (I# (dataToTag# False), I# (dataToTag# True))
-- (0, 1)

-- data Ordering = LT | EQ | GT
-- LT ~ 0
-- EQ ~ 1
-- GT ~ 2

b :: (Int, Int, Int)
b = (I# (dataToTag# LT), I# (dataToTag# EQ), I# (dataToTag# GT))
-- (0, 1, 2)

-- data Either a b = Left a | Right b
-- Left ~ 0
-- Right ~ 1

c :: (Int, Int)
c = (I# (dataToTag# (Left 0)), I# (dataToTag# (Right 1)))
-- (0, 1)
```

String literals included in the source code are also translated into several
primop operations. The ``Addr#`` type in Haskell stands for a static contagious
buffer pre-allocated on the Haskell heap that can hold a ``char*`` sequence. The
operation ``unpackCString#`` can scan this buffer and fold it up into a list of
Chars from inside Haskell.

```haskell
unpackCString# :: Addr# -> [Char]
```

This is done in the early frontend desugarer phase, where literals are
translated into ``Addr#`` inline instead of giant chain of Cons'd characters. So
our "Hello World" translates into the following Core:

```haskell
-- print "Hello World"
print (unpackCString# "Hello World"#)
```

See:

* [Unboxed Values as First-Class Citizens](http://www.haskell.org/ghc/docs/papers/unboxed-values.ps.gz)

IO/ST
-----

Both the IO and the ST monad have special state in the GHC runtime and share a
very similar implementation. Both ``ST a`` and ``IO a`` are passing around an
unboxed tuple of the form:

```haskell
(# token, a #)
```

The ``RealWorld#`` token is "deeply magical" and doesn't actually expand into
any code when compiled, but simply threaded around through every bind of the IO
or ST monad and has several properties of being unique and not being able to be
duplicated to ensure sequential IO actions are actually sequential.
``unsafePerformIO`` can thought of as the unique operation which discards the
world token and plucks the ``a`` out, and is as the name implies not normally
safe.

The ``PrimMonad`` abstracts over both these monads with an associated data
family for the world token or ST thread, and can be used to write operations
that generic over both ST and IO.  This is used extensively inside of the vector
package to allow vector algorithms to be written generically either inside of IO
or ST.

~~~~ {.haskell include="src/29-ghc/io_impl.hs"}
~~~~

~~~~ {.haskell include="src/29-ghc/monad_prim.hs"}
~~~~

See:

* [Evaluation order and state tokens](https://www.fpcomplete.com/user/snoyberg/general-haskell/advanced/evaluation-order-and-state-tokens)


ghc-heap-view
-------------

Through some dark runtime magic we can actually inspect the ``StgClosure``
structures at runtime using various C and Cmm hacks to probe at the fields of
the structure's representation to the runtime. The library ``ghc-heap-view`` can
be used to introspect such things, although there is really no use for this kind
of thing in everyday code it is very helpful when studying the GHC internals to
be able to inspect the runtime implementation details and get at the raw bits
underlying all Haskell types.

~~~~ {.haskell include="src/29-ghc/heapview.hs"}
~~~~

A constructor (in this for cons constructor of list type) is represented by a
``CONSTR`` closure that holds two pointers to the head and the tail. The integer
in the head argument is a static reference to the pre-allocated number and we
see a single static reference in the SRT (static reference table).

```haskell
ConsClosure {
  info = StgInfoTable {
    ptrs = 2,
    nptrs = 0,
    tipe = CONSTR_2_0,
    srtlen = 1
  },
  ptrArgs = [0x000000000074aba8/1,0x00007fca10504260/2],
  dataArgs = [],
  pkg = "ghc-prim",
  modl = "GHC.Types",
  name = ":"
}
```

We can also observe the evaluation and update of a thunk in process ( ``id
(1+1)`` ). The initial thunk is simply a thunk type with a pointer to the code
to evaluate it to a value.

```haskell
ThunkClosure {
  info = StgInfoTable {
    ptrs = 0,
    nptrs = 0,
    tipe = THUNK,
    srtlen = 9
  },
  ptrArgs = [],
  dataArgs = []
}
```

When forced it is then evaluated and replaced with an Indirection closure which
points at the computed value.

```haskell
BlackholeClosure {
  info = StgInfoTable {
    ptrs = 1,
    nptrs = 0,
    tipe = BLACKHOLE,
    srtlen = 0
  },
  indirectee = 0x00007fca10511e88/1
}
```

When the copying garbage collector passes over the indirection, it then simply
replaces the indirection with a reference to the actual computed value computed
by ``indirectee`` so that future access does need to chase a pointer through the
indirection pointer to get the result.

```haskell
ConsClosure {
  info = StgInfoTable {
    ptrs = 0,
    nptrs = 1,
    tipe = CONSTR_0_1,
    srtlen = 0
  },
  ptrArgs = [],
  dataArgs = [2],
  pkg = "integer-gmp",
  modl = "GHC.Integer.Type",
  name = "S#"
}
```

STG
---

After being compiled into Core, a program is translated into a very similar
intermediate form known as STG ( Spineless Tagless G-Machine ) an abstract
machine model that makes all laziness explicit. The spineless indicates that
function applications in the language do not have a spine of applications of
functions are collapsed into a sequence of arguments. Currying is still present
in the semantics since arity information is stored and partially applied
functions will evaluate differently than saturated functions.

```haskell
-- Spine
f x y z = App (App (App f x) y) z

-- Spineless
f x y z = App f [x, y, z]
```

All let statements in STG bind a name to a *lambda form*. A lambda form with no
arguments is a thunk, while a lambda-form with arguments indicates that a
closure is to be allocated that captures the variables explicitly mentioned.

Thunks themselves are either reentrant (``\r``) or updatable (``\u``) indicating
that the thunk and either yields a value to the stack or is allocated on the
heap after the update frame is evaluated All subsequent entry's of the thunk
will yield the already-computed value without needing to redo the same work.

A lambda form also indicates the *static reference table* a collection of
references to static heap allocated values referred to by the body of the
function.

For example turning on ``-ddump-stg`` we can see the expansion of the following
compose function.

```haskell
-- Frontend
compose f g = \x -> f (g x)
```

```haskell
-- Core
compose :: forall t t1 t2. (t1 -> t) -> (t2 -> t1) -> t2 -> t
compose =
  \ (@ t) (@ t1) (@ t2) (f :: t1 -> t) (g :: t2 -> t1) (x :: t2) ->
    f (g x)
```

```haskell
-- STG
compose :: forall t t1 t2. (t1 -> t) -> (t2 -> t1) -> t2 -> t =
    \r [f g x] let { sat :: t1 = \u [] g x; } in  f sat;
SRT(compose): []
```

For a more sophisticated example, let's trace the compilation of the factorial
function.

```haskell
-- Frontend
fac :: Int -> Int -> Int
fac a 0 = a
fac a n = fac (n*a) (n-1)
```

```haskell
-- Core
Rec {
fac :: Int -> Int -> Int
fac =
  \ (a :: Int) (ds :: Int) ->
    case ds of wild { I# ds1 ->
    case ds1 of _ {
      __DEFAULT ->
        fac (* @ Int $fNumInt wild a) (- @ Int $fNumInt wild (I# 1));
      0 -> a
    }
    }
end Rec }
```

```haskell
-- STG
fac :: Int -> Int -> Int =
    \r srt:(0,*bitmap*) [a ds]
        case ds of wild {
          I# ds1 ->
              case ds1 of _ {
                __DEFAULT ->
                    let {
                      sat :: Int =
                          \u srt:(1,*bitmap*) []
                              let { sat :: Int = NO_CCS I#! [1]; } in  - $fNumInt wild sat; } in
                    let { sat :: Int = \u srt:(1,*bitmap*) [] * $fNumInt wild a;
                    } in  fac sat sat;
                0 -> a;
              };
        };
SRT(fac): [fac, $fNumInt]
```

Notice that the factorial function allocates two thunks ( look for ``\u``)
inside of the loop which are updated when computed. It also includes static
references to both itself (for recursion) and the dictionary for instance of
``Num`` typeclass over the type ``Int``.

Worker/Wrapper
--------------

With ``-O2`` turned on GHC will perform a special optimization known as the
Worker-Wrapper transformation which will split the logic of the factorial
function across two definitions, the worker will operate over stack unboxed
allocated machine integers which compiles into a tight inner loop while the
wrapper calls into the worker and collects the end result of the loop and
packages it back up into a boxed heap value. This can often be an order of of
magnitude faster than the naive implementation which needs to pack and unpack
the boxed integers on every iteration.

```haskell
-- Worker
$wfac :: Int# -> Int# -> Int# =
    \r [ww ww1]
        case ww1 of ds {
          __DEFAULT ->
              case -# [ds 1] of sat {
                __DEFAULT ->
                    case *# [ds ww] of sat { __DEFAULT -> $wfac sat sat; };
              };
          0 -> ww;
        };
SRT($wfac): []

-- Wrapper
fac :: Int -> Int -> Int =
    \r [w w1]
        case w of _ {
          I# ww ->
              case w1 of _ {
                I# ww1 -> case $wfac ww ww1 of ww2 { __DEFAULT -> I# [ww2]; };
              };
        };
SRT(fac): []
```

See:

* [Writing Haskell as Fast as C](https://donsbot.wordpress.com/2008/05/06/write-haskell-as-fast-as-c-exploiting-strictness-laziness-and-recursion/)

Z-Encoding
----------

The Z-encoding is Haskell's convention for generating names that are safely
represented in the compiler target language. Simply put the z-encoding renames
many symbolic characters into special sequences of the z character.

String     Z-Encoded String
------     ----------------
``foo``    ``foo``
``z``      ``zz``
``Z``      ``ZZ``
``.``      ``.``
``()``     ``Z0T``
``(,)``    ``Z2T``
``(,,)``   ``Z3T``
``_``      ``zu``
``(``      ``ZL``
``)``      ``ZR``
``:``      ``ZC``
``#``      ``zh``
``.``      ``zi``
``(#,#)``  ``Z2H``
``(->)``   ``ZLzmzgZR``

In this way we don't have to generate unique unidentifiable names for character
rich names and can simply have a straightforward way to translate them into
something unique but identifiable.

So for some example names from GHC generated code:

Z-Encoded String                        Decoded String
--------------------------------        -------------
``ZCMain_main_closure``                 ``:Main_main_closure``
``base_GHCziBase_map_closure``          ``base_GHC.Base_map_closure``
``base_GHCziInt_I32zh_con_info``        ``base_GHC.Int_I32#_con_info``
``ghczmprim_GHCziTuple_Z3T_con_info``   ``ghc-prim_GHC.Tuple_(,,)_con_in``
``ghczmprim_GHCziTypes_ZC_con_info``    ``ghc-prim_GHC.Types_:_con_info``

Cmm
---

Cmm is GHC's complex internal intermediate representation that maps directly
onto the generated code for the compiler target. Cmm code code generated from
Haskell is CPS-converted, all functions never return a value, they simply call
the next frame in the continuation stack. All evaluation of functions proceed by
indirectly jumping to a code object with its arguments placed on the stack by
the caller.

This is drastically different than C's evaluation model, where are placed on the
stack and a function yields a value to the stack after it returns.

There are several common suffixes you'll see used in all closures and function
names:

Symbol   Meaning
------   ----------------
``0``    No argument
``p``    Garage Collected Pointer
``n``    Word-sized non-pointer
``l``    64-bit non-pointer (long)
``v``    Void
``f``    Float
``d``    Double
``v16``  16-byte vector
``v32``  32-byte vector
``v64``  64-byte vector

**Cmm Registers**

There are 10 registers that described in the machine model. **Sp** is the
pointer to top of the stack, **SpLim** is the pointer to last element in the
stack. **Hp** is the heap pointer, used for allocation and garbage collection
with **HpLim** the current heap limit.

The **R1** register always holds the active closure, and subsequent registers
are arguments passed in registers. Functions with more than 10 values spill into
memory.

* Sp
* SpLim
* Hp
* HpLim
* HpAlloc
* R1
* R2
* R3
* R4
* R5
* R6
* R7
* R8
* R9
* R10

**Examples**

To understand Cmm it is useful to look at the code generated by the equivalent
Haskell and slowly understand the equivalence and mechanical translation maps
one to the other.

There are generally two parts to every Cmm definition, the **info table** and
the **entry code**. The info table maps directly ``StgInfoTable`` struct and
contains various fields related to the type of the closure, its payload, and
references. The code objects are basic blocks of generated code that correspond
to the logic of the Haskell function/constructor.

For the simplest example consider a constant static constructor. Simply a
function which yields the Unit value. In this case the function is simply a
constructor with no payload, and is statically allocated.

Haskell:

```haskell
unit = ()
```

Cmm:

```cpp
[section "data" {
     unit_closure:
         const ()_static_info;
 }]
```

Consider a static constructor with an argument.

Haskell:

```haskell
con :: Maybe ()
con = Just ()
```

Cmm:

```cpp
[section "data" {
     con_closure:
         const Just_static_info;
         const ()_closure+1;
         const 1;
 }]
```

Consider a literal constant. This is a static value.

Haskell:

```haskell
lit :: Int
lit = 1
```

Cmm:

```cpp
[section "data" {
     lit_closure:
         const I#_static_info;
         const 1;
 }]
```

Consider the identity function.

Haskell:

```haskell
id x = x
```

Cmm:

```cpp
[section "data" {
     id_closure:
         const id_info;
 },
 id_info()
         { label: id_info
           rep:HeapRep static { Fun {arity: 1 fun_type: ArgSpec 5} }
         }
     ch1:
         R1 = R2;
         jump stg_ap_0_fast; // [R1]
 }]
```

Consider the constant function.

Haskell:

```haskell
constant x y = x
```

Cmm:

```cpp
[section "data" {
     constant_closure:
         const constant_info;
 },
 constant_info()
         { label: constant_info
           rep:HeapRep static { Fun {arity: 2 fun_type: ArgSpec 12} }
         }
     cgT:
         R1 = R2;
         jump stg_ap_0_fast; // [R1]
 }]
```

Consider a function where application of a function ( of unknown arity ) occurs.

Haskell:

```haskell
compose f g x = f (g x)
```

Cmm:

```cpp
[section "data" {
     compose_closure:
         const compose_info;
 },
 compose_info()
         { label: compose_info
           rep:HeapRep static { Fun {arity: 3 fun_type: ArgSpec 20} }
         }
     ch9:
         Hp = Hp + 32;
         if (Hp > HpLim) goto chd;
         I64[Hp - 24] = stg_ap_2_upd_info;
         I64[Hp - 8] = R3;
         I64[Hp + 0] = R4;
         R1 = R2;
         R2 = Hp - 24;
         jump stg_ap_p_fast; // [R1, R2]
     che:
         R1 = compose_closure;
         jump stg_gc_fun; // [R1, R4, R3, R2]
     chd:
         HpAlloc = 32;
         goto che;
 }]
```

Consider a function which branches using pattern matching:

Haskell:

```haskell
match :: Either a a -> a
match x = case x of
  Left a -> a
  Right b -> b
```

Cmm:

```cpp
[section "data" {
     match_closure:
         const match_info;
 },
 sio_ret()
         { label: sio_info
           rep:StackRep []
         }
     ciL:
         _ciM::I64 = R1 & 7;
         if (_ciM::I64 >= 2) goto ciN;
         R1 = I64[R1 + 7];
         Sp = Sp + 8;
         jump stg_ap_0_fast; // [R1]
     ciN:
         R1 = I64[R1 + 6];
         Sp = Sp + 8;
         jump stg_ap_0_fast; // [R1]
 },
 match_info()
         { label: match_info
           rep:HeapRep static { Fun {arity: 1 fun_type: ArgSpec 5} }
         }
     ciP:
         if (Sp - 8 < SpLim) goto ciR;
         R1 = R2;
         I64[Sp - 8] = sio_info;
         Sp = Sp - 8;
         if (R1 & 7 != 0) goto ciU;
         jump I64[R1]; // [R1]
     ciR:
         R1 = match_closure;
         jump stg_gc_fun; // [R1, R2]
     ciU: jump sio_info; // [R1]
 }]
```

**Macros**

Cmm itself uses many macros to stand for various constructs, many of which are
defined in an external C header file. A short reference for the common types:

Cmm      Description
------   ----------
``C_``   char
``D_``   double
``F_``   float
``W_``   word
``P_``   garbage collected pointer
``I_``   int
``L_``   long
``FN_``  function pointer (no arguments)
``EF_``  extern function pointer
``I8``   8-bit integer
``I16``  16-bit integer
``I32``  32-bit integer
``I64``  64-bit integer


Many of the predefined closures (``stg_ap_p_fast``, etc) are themselves
mechanically generated and more or less share the same form ( a giant switch
statement on closure type, update frame, stack adjustment). Inside of GHC is a
file named ``GenApply.hs`` that generates most of these functions.  See the Gist
link in the reading section for the current source file that GHC generates.  For
example the output for ``stg_ap_p_fast``.

```cpp
stg_ap_p_fast
{   W_ info;
    W_ arity;
    if (GETTAG(R1)==1) {
        Sp_adj(0);
        jump %GET_ENTRY(R1-1) [R1,R2];
    }
    if (Sp - WDS(2) < SpLim) {
        Sp_adj(-2);
        W_[Sp+WDS(1)] = R2;
        Sp(0) = stg_ap_p_info;
        jump __stg_gc_enter_1 [R1];
    }
    R1 = UNTAG(R1);
    info = %GET_STD_INFO(R1);
    switch [INVALID_OBJECT .. N_CLOSURE_TYPES] (TO_W_(%INFO_TYPE(info))) {
        case FUN,
             FUN_1_0,
             FUN_0_1,
             FUN_2_0,
             FUN_1_1,
             FUN_0_2,
             FUN_STATIC: {
            arity = TO_W_(StgFunInfoExtra_arity(%GET_FUN_INFO(R1)));
            ASSERT(arity > 0);
            if (arity == 1) {
                Sp_adj(0);
                R1 = R1 + 1;
                jump %GET_ENTRY(UNTAG(R1)) [R1,R2];
            } else {
                Sp_adj(-2);
                W_[Sp+WDS(1)] = R2;
                if (arity < 8) {
                  R1 = R1 + arity;
                }
                BUILD_PAP(1,1,stg_ap_p_info,FUN);
            }
        }
        default: {
            Sp_adj(-2);
            W_[Sp+WDS(1)] = R2;
            jump RET_LBL(stg_ap_p) [];
        }
    }
}
```

Handwritten Cmm can be included in a module manually by first compiling it
through GHC into an object and then using a special FFI invocation.

~~~~ {.cpp include="src/29-ghc/factorial.cmm"}
~~~~

~~~~ {.haskell include="src/29-ghc/cmm_include.hs"}
~~~~

See:

* [CmmType](http://hackage.haskell.org/trac/ghc/wiki/Commentary/Compiler/CmmType)
* [MiscClosures](https://github.com/ghc/ghc/blob/master/includes/stg/MiscClosures.h)
* [StgCmmArgRep](https://github.com/ghc/ghc/blob/master/compiler/codeGen/StgCmmArgRep.hs)

Cmm Runtime:

* [Apply.cmm](https://github.com/ghc/ghc/blob/master/rts/Apply.cmm)
* [StgStdThunks.cmm](https://github.com/ghc/ghc/blob/master/rts/StgStdThunks.cmm)
* [StgMiscClosures.cmm](https://github.com/ghc/ghc/blob/master/rts/StgMiscClosures.cmm)
* [PrimOps.cmm](https://github.com/ghc/ghc/blob/master/rts/PrimOps.cmm)
* [Updates.cmm](https://github.com/ghc/ghc/blob/master/rts/Updates.cmm)
* [Precompiled Closures ( Autogenerated Output )](https://gist.github.com/sdiehl/e5c9daab7a6d1da0ede7)

Optimization Hacks
------------------

**Tables Next to Code**

GHC will place the info table for a toplevel closure directly next to the
entry-code for the objects in memory such that the fields from the info table
can be accessed by pointer arithmetic on the function pointer to the code
itself. Not performing this optimization would involve chasing through one more
pointer to get to the info table. Given how often info-tables are accessed using
the tables-next-to-code optimization results in a tractable speedup.

**Pointer Tagging**

Depending on the type of the closure involved, GHC will utilize the last few
bits in a pointer to the closure to store information that can be read off from
the bits of pointer itself before jumping into or access the info tables. For
thunks this can be information like whether it is evaluated to WHNF or not, for
constructors it contains the constructor tag (if it fits) to avoid an info table
lookup.

Depending on the architecture the tag bits are either the last 2 or 3 bits of a
pointer.

```cpp
// 32 bit arch
TAG_BITS = 2

// 64-bit arch
TAG_BITS = 3
```

These occur in Cmm most frequently via the following macro definitions:

```cpp
#define TAG_MASK ((1 << TAG_BITS) - 1)
#define UNTAG(p) (p & ~TAG_MASK)
#define GETTAG(p) (p & TAG_MASK)
```

So for instance in many of the precompiled functions, there will be a test for
whether the active closure ``R1`` is already evaluated.

```cpp
if (GETTAG(R1)==1) {
    Sp_adj(0);
    jump %GET_ENTRY(R1-1) [R1,R2];
}
```

Profiling
=========

EKG
---

EKG is a monitoring tool that can monitor various aspect of GHC's runtime
alongside an active process. The interface for the output is viewable within a
browser interface. The monitoring process is forked off (in a system thread)
from the main process.

~~~~ {.haskell include="src/29-ghc/ekg.hs"}
~~~~

![](img/ekg.png)

RTS Profiling
-------------

The GHC runtime system can be asked to dump information about

```haskell
$ ./program +RTS -s

       1,939,784 bytes allocated in the heap
          11,160 bytes copied during GC
          44,416 bytes maximum residency (2 sample(s))
          21,120 bytes maximum slop
               1 MB total memory in use (0 MB lost due to fragmentation)

                                    Tot time (elapsed)  Avg pause  Max pause
  Gen  0         2 colls,     0 par    0.00s    0.00s     0.0000s    0.0000s
  Gen  1         2 colls,     0 par    0.00s    0.00s     0.0002s    0.0003s

  INIT    time    0.00s  (  0.00s elapsed)
  MUT     time    0.00s  (  0.01s elapsed)
  GC      time    0.00s  (  0.00s elapsed)
  EXIT    time    0.00s  (  0.00s elapsed)
  Total   time    0.01s  (  0.01s elapsed)

  %GC     time       5.0%  (7.1% elapsed)

  Alloc rate    398,112,898 bytes per MUT second

  Productivity  91.4% of total user, 128.8% of total elapsed
```

Productivity indicates the amount of time spent during execution compared to the
time spent garbage collecting. Well tuned CPU bound programs are often in the
90-99% range of productivity range.

In addition individual function profiling information can be generated by
compiling the program with ``-prof`` flag. The resulting information is
outputted to a ``.prof`` file of the same name as the module. This is useful for
tracking down hotspots in the program.

```haskell
$ ghc -O2 program.hs -prof -auto-all
$ ./program +RTS -p
$ cat program.prof
        Mon Oct 27 23:00 2014 Time and Allocation Profiling Report  (Final)

           program +RTS -p -RTS

        total time  =        0.01 secs   (7 ticks @ 1000 us, 1 processor)
        total alloc =   1,937,336 bytes  (excludes profiling overheads)

COST CENTRE MODULE           %time %alloc

CAF         Main             100.0   97.2
CAF         GHC.IO.Handle.FD   0.0    1.8


                                                      individual     inherited
COST CENTRE MODULE                  no.     entries  %time %alloc   %time %alloc

MAIN        MAIN                     42           0    0.0    0.7   100.0  100.0
 CAF        Main                     83           0  100.0   97.2   100.0   97.2
 CAF        GHC.IO.Encoding          78           0    0.0    0.1     0.0    0.1
 CAF        GHC.IO.Handle.FD         77           0    0.0    1.8     0.0    1.8
 CAF        GHC.Conc.Signal          74           0    0.0    0.0     0.0    0.0
 CAF        GHC.IO.Encoding.Iconv    69           0    0.0    0.0     0.0    0.0
 CAF        GHC.Show                 60           0    0.0    0.0     0.0    0.0
```

Languages
=========

Unbound
-------

Several libraries exist to mechanize the process of writing name capture and
substitution, since it is largely mechanical. Probably the most robust is the
``unbound`` library.  For example we can implement the infer function for a
small Hindley-Milner system over a simple typed lambda calculus without having
to write the name capture and substitution mechanics ourselves.

~~~~ {.haskell include="src/30-languages/unbound.hs"}
~~~~

Unbound Generics
----------------

Recently unbound was ported to use GHC.Generics instead of Template Haskell. The
API is effectively the same, so for example a simple lambda calculus could be
written as:

~~~~ {.haskell include="src/30-languages/unbound-generics.hs"}
~~~~

See:

* [unbound-generics](https://github.com/lambdageek/unbound-generics)

LLVM
----

LLVM is a library for generating machine code. The llvm-general bindings provide a way to model, compile and
execute LLVM bytecode from within the Haskell runtime.

See:

* [Implementing a JIT Compiled Language with Haskell and LLVM](http://www.stephendiehl.com/llvm/)

Printer Combinators
-------------------

Pretty printer combinators compose logic to print strings.

              Combinators
-----------   ------------
``<>``        Concatenation
``<+>``       Spaced concatenation
``char``      Renders a character as a ``Doc``
``text``      Renders a string as a ``Doc``

~~~~ {.haskell include="src/30-languages/pretty.hs"}
~~~~

The pretty printed form of the ``k`` combinator:

```haskell
\f g x . (f (g x))
```

The ``Text.Show.Pretty`` library can be used to pretty print nested data structures in a more human readable
form for any type that implements ``Show``.  For example a dump of the structure for the AST of SK combinator
with ``ppShow``.

```haskell
App
  (Lam
     "f" (Lam "g" (Lam "x" (App (Var "f") (App (Var "g") (Var "x"))))))
  (Lam "x" (Lam "y" (Var "x")))
```

Adding the following to your ghci.conf can be useful for working with deeply nested structures interactively.

```haskell
import Text.Show.Pretty (ppShow)
let pprint x = putStrLn $ ppShow x
```

See: [The Design of a Pretty-printing Library](http://belle.sourceforge.net/doc/hughes95design.pdf)

Haskeline
---------

Haskeline is cross-platform readline support which plays nice with GHCi as well.

```haskell
runInputT :: Settings IO -> InputT IO a -> IO a
getInputLine :: String -> InputT IO (Maybe String)
```

~~~~ {.haskell include="src/30-languages/haskelline.hs"}
~~~~

Template Haskell
================

准引用（Quasiquotation）
-------------

使用准引用可以表达用宿主语言以外的语法定义的语法块。和写一大堆字符串不同，这部分内容会被解析为宿主语言支持的AST（抽象语法树）数据。可以通过
用户定义逻辑将宿主语言中的数据注入到自定义的语言中去，从而实现两者之间的数据交换。

在实践中，使用准引用可以实现DSL（领域特定语言）或完全通过代码生成来与其他语言进行集成。

我们已经介绍过如何写一个Parsec解析器，下面我们为它写一个准引用。

~~~~ {.haskell include="src/31-template-haskell/Quasiquote.hs"}
~~~~

测试一下看看：

~~~~ {.haskell include="src/31-template-haskell/quasiquote_use.hs"}
~~~~

这里有一个至关重要的特性：通过保留位置信息，可以由内嵌语言中的错误回溯到宿主语言代码的特定行。

C的准引用
----------------

由于可以实现任意的解析器，你可能会希望完全嵌入另一种语言的AST，比如C或CUDA C。

```haskell
hello :: String -> C.Func
hello msg = [cfun|

int main(int argc, const char *argv[])
{
    printf($msg);
    return 0;
}

|]
```

对它求值，则可以得到这段C程序的AST。接着我们就可以对它进行操作，或使用``ppr``函数输出回C代码。

```haskell
Func
  (DeclSpec [] [] (Tint Nothing))
  (Id "main")
  DeclRoot
  (Params
     [ Param (Just (Id "argc")) (DeclSpec [] [] (Tint Nothing)) DeclRoot
     , Param
         (Just (Id "argv"))
         (DeclSpec [] [ Tconst ] (Tchar Nothing))
         (Array [] NoArraySize (Ptr [] DeclRoot))
     ]
     False)
  [ BlockStm
      (Exp
         (Just
            (FnCall
               (Var (Id "printf"))
               [ Const (StringConst [ "\"Hello Haskell!\"" ] "Hello Haskell!")
               ])))
  , BlockStm (Return (Just (Const (IntConst "0" Signed 0))))
  ]
```

上面的例子中，我们在printf语句中嵌入了反向引用的Haskell字符串，除此之外，我们还可以传入和传出其他类型的数据，如标识符、数字，或其他实现了
``Lift``类型类的表达式。

我们可以使用CUDA C方言来生成生成一段C程序，可以通过CUDA kernel跑在GPU上。

~~~~ {.haskell include="src/31-template-haskell/cquote.hs"}
~~~~

执行程序，得到如下结果：

```cpp
__global__ void saxpy(float* x, float* y)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < 65536) {
        y[i] = 2.0 * x[i] + y[i];
    }
}
int driver(float* x, float* y)
{
    float* d_x, * d_y;

    cudaMalloc(&d_x, 65536 * sizeof(float));
    cudaMalloc(&d_y, 65536 * sizeof(float));
    cudaMemcpy(d_x, x, 65536, cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, y, 65536, cudaMemcpyHostToDevice);
    saxpy<<<(65536 + 255) / 256, 256>>>(d_x, d_y);
    return 0;
}
```

使用``nvcc -ptx -c``执行上述输出的程序，可以得到相关的PTX（译者注：Parallel Thread Execution（并行线程执行））代码。

Template Haskell
----------------

Of course the most useful case of quasiquotation is the ability to procedurally generate Haskell code itself
from inside of Haskell. The ``template-haskell`` framework provides four entry points for the quotation to
generate various types of Haskell declarations and expressions.

Type         Quasiquoted     Class
------------ --------------  -----------
``Q Exp``    ``[e| ... |]``  expression
``Q Pat ``   ``[p| ... |]``  pattern
``Q Type``   ``[t| ... |]``  type
``Q [Dec]``  ``[d| ... |]``  declaration

```haskell
data QuasiQuoter = QuasiQuoter
  { quoteExp  :: String -> Q Exp
  , quotePat  :: String -> Q Pat
  , quoteType :: String -> Q Type
  , quoteDec  :: String -> Q [Dec]
  }
```

The logic evaluating, splicing, and introspecting compile-time values is embedded within the Q monad, which
has a ``runQ`` which can be used to evaluate its context. These functions of this monad is deeply embedded in
the implementation of GHC.

```haskell
runQ :: Quasi m => Q a -> m a
runIO :: IO a -> Q a
```

Just as before, TemplateHaskell provides the ability to lift Haskell values into the their AST quantities
within the quoted expression using the Lift type class.

```haskell
class Lift t where
  lift :: t -> Q Exp

instance Lift Integer where
  lift x = return (LitE (IntegerL x))

instance Lift Int where
  lift x= return (LitE (IntegerL (fromIntegral x)))

instance Lift Char where
  lift x = return (LitE (CharL x))

instance Lift Bool where
  lift True  = return (ConE trueName)
  lift False = return (ConE falseName)

instance Lift a => Lift (Maybe a) where
  lift Nothing  = return (ConE nothingName)
  lift (Just x) = liftM (ConE justName `AppE`) (lift x)

instance Lift a => Lift [a] where
  lift xs = do { xs' <- mapM lift xs; return (ListE xs') }
```

In many cases Template Haskell can be used interactively to explore the AST form of various Haskell syntax.

```haskell
λ: runQ [e| \x -> x |]
LamE [VarP x_2] (VarE x_2)

λ: runQ [d| data Nat = Z | S Nat |]
[DataD [] Nat_0 [] [NormalC Z_2 [],NormalC S_1 [(NotStrict,ConT Nat_0)]] []]

λ: runQ [p| S (S Z)|]
ConP Singleton.S [ConP Singleton.S [ConP Singleton.Z []]]

λ: runQ [t| Int -> [Int] |]
AppT (AppT ArrowT (ConT GHC.Types.Int)) (AppT ListT (ConT GHC.Types.Int))

λ: let g = $(runQ [| \x -> x |])

λ: g 3
3
```

Using
[Language.Haskell.TH](http://hackage.haskell.org/package/template-haskell-2.4.0.0/docs/Language-Haskell-TH-Syntax.html#t:Dec)
we can piece together Haskell AST element by element but subject to our own custom logic to generate the code.
This can be somewhat painful though as the source-language (called ``HsSyn``) to Haskell is enormous,
consisting of around 100 nodes in its AST many of which are dependent on the state of language pragmas.

```haskell
-- builds the function (f = \(a,b) -> a)
f :: Q [Dec]
f = do
  let f = mkName "f"
  a <- newName "a"
  b <- newName "b"
  return [ FunD f [ Clause [TupP [VarP a, VarP b]] (NormalB (VarE a)) [] ] ]
```

```haskell
my_id :: a -> a
my_id x = $( [| x |] )

main = print (my_id "Hello Haskell!")
```

As a debugging tool it is useful to be able to dump the reified information out for a given symbol
interactively, to do so there is a simple little hack.

~~~~ {.haskell include="src/31-template-haskell/template_info.hs"}
~~~~

```haskell
λ: $(introspect 'id)
VarI
  GHC.Base.id
  (ForallT
     [ PlainTV a_1627405383 ]
     []
     (AppT (AppT ArrowT (VarT a_1627405383)) (VarT a_1627405383)))
  Nothing
  (Fixity 9 InfixL)


λ: $(introspect ''Maybe)
TyConI
  (DataD
     []
     Data.Maybe.Maybe
     [ PlainTV a_1627399528 ]
     [ NormalC Data.Maybe.Nothing []
     , NormalC Data.Maybe.Just [ ( NotStrict , VarT a_1627399528 ) ]
     ]
     [])
```

```haskell
import Language.Haskell.TH

foo :: Int -> Int
foo x = x + 1

data Bar

fooInfo :: InfoQ
fooInfo = reify 'foo

barInfo :: InfoQ
barInfo = reify ''Bar
```

```haskell
$( [d| data T = T1 | T2 |] )

main = print [T1, T2]
```

Splices are indicated by ``$(f)`` syntax for the expression level and at the toplevel simply by invocation of
the template Haskell function. Running GHC with ``-ddump-splices`` shows our code being spliced in at the
specific location in the AST at compile-time.

```haskell
$(f)

template_haskell_show.hs:1:1: Splicing declarations
    f
  ======>
    template_haskell_show.hs:8:3-10
    f (a_a5bd, b_a5be) = a_a5bd
```

~~~~ {.haskell include="src/31-template-haskell/Splice.hs"}
~~~~

~~~~ {.haskell include="src/31-template-haskell/Insert.hs"}
~~~~

At the point of the splice all variables and types used must be in scope, so it must appear after their
declarations in the module. As a result we often have to mentally topologically sort our code when using
TemplateHaskell such that declarations are defined in order.

See: [Template Haskell AST](http://hackage.haskell.org/package/template-haskell-2.9.0.0/docs/Language-Haskell-TH.html#t:Exp)

Antiquotation
-------------

Extending our quasiquotation from above now that we have TemplateHaskell machinery we can implement the same
class of logic that it uses to pass Haskell values in and pull Haskell values out via pattern matching on
templated expressions.

~~~~ {.haskell include="src/31-template-haskell/Antiquote.hs"}
~~~~

~~~~ {.haskell include="src/31-template-haskell/use_antiquote.hs"}
~~~~

Templated Type Families
----------------------

Just like at the value-level we can construct type-level constructions by piecing together their AST.

```haskell
Type          AST
----------    ----------
t1 -> t2      ArrowT `AppT` t2 `AppT` t2
[t]           ListT `AppT` t
(t1,t2)       TupleT 2 `AppT` t1 `AppT` t2
```

For example consider that type-level arithmetic is still somewhat incomplete in GHC 7.6, but there often cases
where the span of typelevel numbers is not full set of integers but is instead some bounded set of numbers. We
can instead define operations with a type-family instead of using an inductive definition ( which often
requires manual proofs ) and simply enumerates the entire domain of arguments to the type-family and maps them
to some result computed at compile-time.

For example the modulus operator would be non-trivial to implement at type-level but instead we can use the
``enumFamily`` function to splice in type-family which simply enumerates all possible pairs of numbers up to a
desired depth.

~~~~ {.haskell include="src/31-template-haskell/EnumFamily.hs"}
~~~~

~~~~ {.haskell include="src/31-template-haskell/enum_family_splice.hs"}
~~~~

In practice GHC seems fine with enormous type-family declarations although compile-time may
increase a bit as a result.

The singletons library also provides a way to automate this process by letting us write seemingly value-level
declarations inside of a quasiquoter and then promoting the logic to the type-level. For example if we wanted
to write a value-level and type-level map function for our HList this would normally involve quite a bit of
boilerplate, now it can stated very concisely.

~~~~ {.haskell include="src/31-template-haskell/singleton_promote.hs"}
~~~~

Templated Type Classes
----------------------

Probably the most common use of Template Haskell is the automatic generation of type-class instances. Consider
if we wanted to write a simple Pretty printing class for a flat data structure that derived the ppr method in
terms of the names of the constructors in the AST we could write a simple instance.

~~~~ {.haskell include="src/31-template-haskell/Class.hs"}
~~~~

In a separate file invoke the pretty instance at the toplevel, and with ``--ddump-splice`` if we want to view
the spliced class instance.


~~~~ {.haskell include="src/31-template-haskell/splice_class.hs"}
~~~~

Templated Singletons
--------------------

In the previous discussion about singletons, we introduced quite a bit of boilerplate code to work with the
singletons. This can be partially abated by using Template Haskell to mechanically generate the instances and
classes.

~~~~ {.haskell include="src/31-template-haskell/Singleton.hs"}
~~~~

Trying it out by splicing code at the expression level, type level and as patterns.

~~~~ {.haskell include="src/31-template-haskell/splice_singleton.hs"}
~~~~

The [singletons](https://hackage.haskell.org/package/singletons) package takes this idea to its logical
conclusion allow us to toplevel declarations of seemingly regular Haskell syntax with singletons spliced in,
the end result resembles the constructions in a dependently typed language if one squints hard enough.

~~~~ {.haskell include="src/31-template-haskell/singleton_lib.hs"}
~~~~

After template splicing we see that we now that several new constructs in scope:

```haskell
type SNat a = Sing Nat a

type family IsEven a :: Bool
type family Plus a b :: Nat

sIsEven :: Sing Nat t0 -> Sing Bool (IsEven t0)
splus   :: Sing Nat a -> Sing Nat b -> Sing Nat (Plus a b)
```

Categories
==========

Alas we come to the topic of category theory. Some might say all discussion of
Haskell eventually leads here at one point or another.

Nevertheless the overall importance of category theory in the context of Haskell
has been somewhat overstated and unfortunately mystified to some extent. The
reality is that amount of category theory which is directly applicable to
Haskell roughly amounts to a subset of the first chapter of any undergraduate
text.

Algebraic Relations
-------------------

Grossly speaking category theory is not terribly important to Haskell
programming, and although some libraries derive some inspiration from the
subject most do not. What is more important is a general understanding of
equational reasoning and a familiarity with various algebraic relations.

Certain relations show up so frequently we typically refer to their properties
by name ( often drawn from an equivalent abstract algebra concept ). Consider a
binary operation ``a `op` b``.

**Associativity**

```haskell
a `op` (b `op` c) = (a `op` b) `op` c
```

**Commutativity**

```haskell
a `op` b = b `op` a
```

**Units**

```haskell
a `op` e = a
e `op` a = a
```

**Inversion**

```haskell
(inv a) `op` a = e
a `op` (inv a) = e
```

**Zeros**

```haskell
a `op` e = e
e `op` a = e
```

**Linearity**

```haskell
f (x `op` y) = f x `op` f y
```

**Idempotency**

```haskell
f (f x) = f x
```

**Distributivity**

```haskell
a `f` (b `g` c) = (a `f` b) `g` (a `f` c)
(b `g` c) `f` a = (b `f` a) `g` (c `f` a)
```

**Anticommutativity**

```haskell
a `op` b = inv (b `op` a)
```

And of course combinations of these properties over multiple functions gives
rise to higher order systems of relations that occur over and over again
throughout functional programming, and once we recognize them we can abstract
over them. For instance a monoid is a combination of a unit and a single
associative operation.

Categories
----------

The most basic structure is a category which is an algebraic structure of
objects (``Obj``) and morphisms (``Hom``) with the structure that morphisms
compose associatively and the existence of an identity morphism for each object.

With kind polymorphism enabled we can write down the general category
parameterized by a type variable "c" for category, and the instance ``Hask`` the
category of Haskell types with functions between types as morphisms.

~~~~ {.haskell include="src/33-categories/categories.hs"}
~~~~

Isomorphisms
------------

Two objects of a category are said to be isomorphic if we can construct a
morphism with 2-sided inverse that takes the structure of an object to another
form and back to itself when inverted.

```haskell
f  :: a -> b
f' :: b -> a
```

Such that:

```haskell
f . f' = id
f'. f  = id
```

For example the types ``Either () a`` and ``Maybe a`` are isomorphic.

~~~~ {.haskell include="src/33-categories/iso.hs"}
~~~~

```haskell
data Iso a b = Iso { to :: a -> b, from :: b -> a }

instance Category Iso where
  id = Iso id id
  (Iso f f') . (Iso g g') = Iso (f . g) (g' . f')
```

Duality
-------

One of the central ideas is the notion of duality, that reversing some internal
structure yields a new structure with a "mirror" set of theorems. The dual of a
category reverse the direction of the morphisms forming the category
C<sup>Op</sup>.

~~~~ {.haskell include="src/33-categories/dual.hs"}
~~~~

See:

* [Duality for Haskellers](http://blog.ezyang.com/2012/10/duality-for-haskellers/)

Functors
--------

Functors are mappings between the objects and morphisms of categories that
preserve identities and composition.

~~~~ {.haskell include="src/33-categories/functors.hs"}
~~~~

```haskell
fmap id ≡ id
fmap (a . b) ≡ (fmap a) . (fmap b)
```

Natural Transformations
-----------------------

Natural transformations are mappings between functors that are invariant under
interchange of morphism composition order.

```haskell
type Nat f g = forall a. f a -> g a
```

Such that for a natural transformation ``h`` we have:

```haskell
fmap f . h ≡ h . fmap f
```

The simplest example is between (f = List) and (g = Maybe) types.

```haskell
headMay :: forall a. [a] -> Maybe a
headMay []     = Nothing
headMay (x:xs) = Just x
```

Regardless of how we chase ``safeHead``, we end up with the same result.

```haskell
fmap f (headMay xs) ≡ headMay (fmap f xs)
```

```haskell
fmap f (headMay [])
= fmap f Nothing
= Nothing

headMay (fmap f [])
= headMay []
= Nothing
```

```haskell
fmap f (headMay (x:xs))
= fmap f (Just x)
= Just (f x)

headMay (fmap f (x:xs))
= headMay [f x]
= Just (f x)
```

Or consider the Functor ``(->)``.

```haskell
f :: (Functor t)
  => (->) a b
  -> (->) (t a) (t b)
f = fmap

g :: (b -> c)
  -> (->) a b
  -> (->) a c
g = (.)

c :: (Functor t)
  => (b -> c)
  -> (->) (t a) (t b)
  -> (->) (t a) (t c)
c = f . g
```

```haskell
f . g x = c x . g
```


A lot of the expressive power of Haskell types comes from the interesting fact
that, with a few caveats, polymorphic Haskell functions are natural
transformations.

See: [You Could Have Defined Natural Transformations](http://blog.sigfpe.com/2008/05/you-could-have-defined-natural.html)

Yoneda Lemma
------------

The Yoneda lemma is an elementary, but deep result in Category theory. The
Yoneda lemma states that for any functor ``F``, the types ``F a`` and ``∀ b. (a
-> b) -> F b`` are isomorphic.

```haskell
{-# LANGUAGE RankNTypes #-}

embed :: Functor f => f a -> (forall b . (a -> b) -> f b)
embed x f = fmap f x

unembed :: Functor f => (forall b . (a -> b) -> f b) -> f a
unembed f = f id
```

So that we have:

```haskell
embed . unembed ≡ id
unembed . embed ≡ id
```

The most broad hand-wavy statement of the theorem is that an object in a
category can be represented by the set of morphisms into it, and that the
information about these morphisms alone sufficiently determines all properties
of the object itself.

In terms of Haskell types, given a fixed type ``a`` and a functor ``f``, if we
have some a higher order polymorphic function ``g`` that when given a function
of type ``a -> b`` yields ``f b`` then the behavior ``g`` is entirely determined
by ``a -> b`` and the behavior of ``g`` can written purely in terms of ``f a``.

See:

* [Reverse Engineering Machines with the Yoneda Lemma](http://blog.sigfpe.com/2006/11/yoneda-lemma.html)

Kleisli Category
----------------

Kleisli composition (i.e. Kleisli Fish) is defined to be:

```haskell
(>=>) :: Monad m => (a -> m b) -> (b -> m c) -> a -> m c
f >=> g ≡ \x -> f x >>= g

(<=<) :: Monad m => (b -> m c) -> (a -> m b) -> a -> m c
(<=<) = flip (>=>)
```

The monad laws stated in terms of the Kleisli category of a monad ``m`` are
stated much more symmetrically as one associativity law and two identity laws.

```haskell
(f >=> g) >=> h ≡ f >=> (g >=> h)
return >=> f ≡ f
f >=> return ≡  f
```

Stated simply that the monad laws above are just the category laws in the
Kleisli category.

~~~~ {.haskell include="src/33-categories/kleisli.hs"}
~~~~

For example, ``Just`` is just an identity morphism in the Kleisli category of
the ``Maybe`` monad.

```haskell
Just >=> f ≡ f
f >=> Just ≡ f
```

Resources
---------

* [Category Theory, Awodey](http://www.amazon.com/Category-Theory-Oxford-Logic-Guides/dp/0199237182)
* [Category Theory Foundations](https://www.youtube.com/watch?v=ZKmodCApZwk)
* [The Catsters](http://www.youtube.com/user/TheCatsters)
