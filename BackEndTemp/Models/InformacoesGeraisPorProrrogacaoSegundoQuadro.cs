namespace Models;

public class InformacoesGeraisPorProrrogacaoSegundoQuadro
{
    public int? Prorrogacao { get; set; }

    public decimal? TotalIiAPagar { get; set; }
    public decimal? TotalIpiAPagar { get; set; }
    public decimal? TotalPisAPagar { get; set; }
    public decimal? TotalCofinsAPagar { get; set; }
    public decimal? TotalIcmsAPagar { get; set; }
    public decimal? TotalIiPago { get; set; }
    public decimal? TotalIpiPago { get; set; }
    public decimal? TotalPisPago { get; set; }
    public decimal? TotalCofinsPago { get; set; }
    public decimal? TotalIcmsPago { get; set; }
    public decimal? AfrmmSuspenso { get; set; }
    public decimal? TotalSuspenso { get; set; }
    public string? Apolice { get; set; }
    public DateTime? VencimentoApolice { get; set; }
    public decimal? ValorSeguroAtual { get; set; }
}