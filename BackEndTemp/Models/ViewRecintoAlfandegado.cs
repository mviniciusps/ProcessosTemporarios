using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class ViewRecintoAlfandegado
{
    [Column("Referencia Braslog")]
    public string? RecintoBraslog { get; set; }

    [Column("Recinto Alfandegado")]
    public string? RecintoAlfandegado { get; set; }

    [Column("URF de Despacho")]
    public string? URF { get; set; }

    [Column("Código do Recinto")]
    public string? CodigoRecinto { get; set; }
}
