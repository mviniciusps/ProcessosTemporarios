using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Types;

namespace Models;

public class InserirDadosImportacao
{
    public int? CeId { get; set; }
    public int LogisticaId { get; set; }
    public int ValoresCalculoAduaneiroid { get; set; }
    public int Declaracaoid { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal Frete { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? OutrasDespesas { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? Seguro { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? Capatazias { get; set; }

    [Column(TypeName = "decimal(4,2)")]
    public decimal? TaxaMercante { get; set; }
    public DateTime DataRegistro { get; set; }

    [StringLength(3)]
    public string? MoedaFOB { get; set; }

    [Column(TypeName = "decimal(7,6)")]
    public decimal TaxaCambioFOB { get; set; }

    [StringLength(3)]
    public string? MoedaFrete { get; set; }

    [Column(TypeName = "decimal(7,6)")]
    public decimal? TaxaCambioFrete { get; set; }

    [StringLength(3)]
    public string? MoedaSeguro { get; set; }

    [Column(TypeName = "decimal(7,6)")]
    public decimal? TaxaCambioSeguro { get; set; }

    [StringLength(3)]
    public string? MoedaDespesas { get; set; }

    [Column(TypeName = "decimal(7,6)")]
    public decimal? TaxaCambioDespesas { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public int? Adicoes { get; set; }
    public decimal? TaxaSiscomex { get; set; }

    [Column(TypeName = "decimal(5,2)")]
    public decimal? AliquotaICMS { get; set; }

    public List<Ncm>? Ncm { get; set; }
    public List<Item>? item { get; set; }
    public List<Prorrogacao>? prorrogacao { get; set; }
}