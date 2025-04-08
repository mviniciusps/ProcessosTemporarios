using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class ViewCeMercante
{
    [Column("Referencia Braslog")]
    public string? ReferenciaBraslog { get; set; }

    [Column("Declaração de Importação")]
    public string? DeclaracaoImportacao { get; set; }

    [Column("Número do CE Mercante")]
    public string? NumeroCeMercante { get; set; }

    [Column("Status")]
    public string? StatusCeMercante { get; set; }


}