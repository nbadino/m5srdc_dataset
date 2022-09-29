using Pkg
Pkg.activate(".")

using Term
using GLM, DataFrames, XLSX, Distributions, Plots

download("https://github.com/nbadino/m5srdc_dataset/raw/main/RDCM5S.xlsx","./nb.xlsx")

numbers = DataFrame(
  XLSX.readdata("./nb.xlsx","Foglio1","A2:C19"),
  Array(XLSX.readdata("./nb.xlsx","Foglio1","A1:C1")[1,:])
)

numbers.RdC .= Float64.(numbers.RDC)
numbers.M5S01 .= numbers.M5S / 100
xGrid = range(extrema(numbers.RdC)...)


model_logit =  glm(@formula(M5S01 ~ RdC),numbers,Binomial(),LogitLink())

prediction_logit = predict(model_logit,DataFrame(RdC = xGrid),level=0.95,interval=:confidence)
prediction_logit.RdC = xGrid

plot(prediction_logit.RdC,prediction_logit.prediction,ribbon = (prediction_logit.prediction .- prediction_logit.lower, prediction_logit.upper .- prediction_logit.prediction), label = "Logit Regression")
scatter!(numbers.RdC,numbers.M5S01,label = "Dati Sole24Ore")
xlabel!("Percettori RdC per 100k")
ylabel!("Proporzione votanti M5S")

savefig(plotto,"LogisticaRibbon.png")


