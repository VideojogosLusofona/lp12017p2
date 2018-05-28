# Gnuplot script

# Função linear por troços
f(x)= (x>=1 && x<40) ? 1.5 * x + 8 : (x >= 40) ? 68 : 1/0 

# Intervalo do gráfico
set yrange [0.0:82]
set xrange [0.0:60]

# Etiquetas em X e Y
set xlabel "Level"
set ylabel "maxNPCsForThisLevel"

# Ticks em X e Y
set xtics 5
set ytics 5
set mxtics 5
set mytics 5

# Grid lines style
set style line 100 lt 1 lw 1 lc rgb  "#cccccc"
set style line 101 lt 1 lw 1 lc rgb  "#eeeeee"

# Grid lines
set grid mytics ytics ls 100, ls 101
set grid mxtics xtics ls 100, ls 101

# Desativar legenda
unset key

# Mostrar plot
plot f(x)
