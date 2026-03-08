namespace Models;

public class InformacoesGeraisTodasProrrogacoesPorProcesso
{
    public int Prorrogacao { get; set; }
    public DateTime? InicioProrrogacao { get; set; }
    public DateTime? VencimentoProrrogacao { get; set; }
    public DateTime? InicioRegime { get; set; }
    public int PrazoDias { get; set; }
    public int PrazoMeses { get; set; }
    public decimal TaxaSelic { get; set; }
    public decimal TotalImpostos { get; set; }
    public decimal TotalImpostosPago { get; set; }
}