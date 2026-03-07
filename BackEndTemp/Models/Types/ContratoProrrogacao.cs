using System.ComponentModel.DataAnnotations.Schema;

namespace Types;

public class ContratoProrrogacao
{
    public int? ContratoId { get; set; }
    public string? NomeContrato { get; set; }
    public DateTime? ContratoVencimento { get; set; }
    public string? NumeroApolice { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? ValorSegurado { get; set; }
    public DateTime? VencimentoApolice { get; set; }
}