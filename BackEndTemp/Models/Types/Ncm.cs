using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Types;

public class Ncm
{
    [StringLength(8)]
    public string? NcmCodigo { get; set; }

    [Column(TypeName = "decimal(10,6)")]
    public decimal? AliquotaII { get; set; }

    [Column(TypeName = "decimal(10,6)")]
    public decimal? AliquotaIPI { get; set; }

    [Column(TypeName = "decimal(10,6)")]
    public decimal? AliquotaPIS { get; set; }
    
    [Column(TypeName = "decimal(10,6)")]
    public decimal? AliquotaCOFINS { get; set; }
}