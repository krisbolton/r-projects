deaths = read_csv("uk-male-deaths-1974-2018.csv", skip = 1)
meltdeaths = reshape2::melt(deaths, id.vars = "Year")

meltdeaths$age = as.numeric(meltdeath$variable)

deathgg = ggplot(meltdeaths) +
  geom_raster(aes(x=Year,y=age,fill=value)) +
  scale_x_continuous("Year",expand=c(0,0),breaks=seq(1974,2018,5)) +
  scale_y_continuous("Age",expand=c(0,0),breaks=seq(0,100,10),limits=c(0,100)) +
  scale_fill_viridis("Deaths",trans = "log10") +
  ggtitle("Death Registration vs Age and Year for the United Kingdom") +
  labs(caption = "Data Source: Office of National Statistics (ONS)")

plot_gg(deathgg, multicore=TRUE,height=5,width=6,scale=500)

angles= seq(0,360,length.out = 1441)[-1]
for(i in 1:1440) {
  render_camera(theta=-45+angles[i])
  render_snapshot(filename = sprintf("C:\\Users\\Kris\\Documents\\Death\\death%i.png", i))
}

rgl::rgl.close()
system("ffmpeg -framerate 60 -i C:\\Users\\Kris\\Documents\\Death\\death%d.png -pix_fmt yuv420p C:\\Users\\Kris\\Documents\\death.mp4")
