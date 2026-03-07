using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Types;

public class Prorrogacao
{
    [StringLength(8, MinimumLength = 8)]
    public string? Ncm { get; set; }    
    public int? DeclaracaoItemId { get; set; }

    [Column(TypeName = "decimal(5,2)")]
    public decimal? TaxaSelicAcumulada { get; set; }

    public int? NumeroProrrogacao { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? IiValorProrrogacao { get; set; }

    [Column(TypeName = "decimal(18,2)")]    
    public decimal? IpiValorProrrogacao { get; set; }

    [Column(TypeName = "decimal(18,2)")]    
    public decimal? PisValorProrrogacao { get; set; }

    [Column(TypeName = "decimal(18,2)")]    
    public decimal? CofinsValorProrrogacao { get; set; }

    [Column(TypeName = "decimal(18,2)")]    
    public decimal? IcmsValorProrrogacao { get; set; }
    public DateTime? DataProrrogacao { get; set; }
    public DateTime? VencimentoProrrogacao { get; set; }
}