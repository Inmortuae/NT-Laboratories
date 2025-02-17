NTOP.ConfigData = {
    NTOP_header1 = {name=NTOP.Name,type="category"},

    NTOP_Nil= {name="Nil",default=20,range={0,100},type="float", description="Nil" },
}
NTConfig.AddConfigOptions(NTOP)