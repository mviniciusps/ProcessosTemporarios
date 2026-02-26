namespace Models;

public class InformacoesGeraisPorProrrogacao
{
    public int Prorrogacao { get; set; }
    public DateTime? InicioProrrogacao { get; set; }
    public DateTime? VencimentoProrrogacao { get; set; }
    public DateTime? InicioRegime { get; set; }
    public decimal? TotalImpostos { get; set; }
    public decimal? TotalImpostosPago { get; set; }
}