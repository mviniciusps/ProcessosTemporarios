using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
public class ViewCNPJ
{
    [Column("Razão Social")]
    public string? RazaoSocial { get; set; }

    [Column("CNPJ")]
    public string? CNPJ { get; set; }

    [Column("Endereço")]
    public string? Endereco { get; set; }
}
