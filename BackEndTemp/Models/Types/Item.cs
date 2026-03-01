using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class Item
{
    [StringLength(8, MinimumLength = 8)]
    public string? Ncm { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? ValorFob { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? PesoLiquido { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? ValorAduaneiro { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? IiValor { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? IpiValor { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? PisValor { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? CofinsValor { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? IcmsValor { get; set; }
}