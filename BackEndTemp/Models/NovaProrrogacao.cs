using System.ComponentModel.DataAnnotations.Schema;
using Types;

namespace Models;

public class NovaProrrogacao
{
    public int DeclaracaoId { get; set; }

    [Column(TypeName = "decimal(5,2)")]
    public decimal TaxaSelicAcumulada { get; set; }
    public List<Prorrogacao>? prorrogacao { get; set; }
    public List<ContratoProrrogacao>? contratoProrrogacaos { get; set; }
}