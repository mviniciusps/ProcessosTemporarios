using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;


public class ViewDeclaracao
{
    [Column("Cliente")]
    public string? NomeCliente { get; set; }

    [Column("Declaração de Importação")]
    public string? DeclaracaoImportacao { get; set; }

    [Column("Referencia Braslog")]
    public string? ReferenciaBraslog { get; set; }

    [Column("AFRMM")]
    public string? AfrmmTipo { get; set; }

    [Column("Número do CE Mercante")]
    public string? NumeroCeMercante { get; set; }

    [Column("Prazo solicitado")]
    public DateTime? PrazoSolicitado { get; set; }

    [Column("Data Registro")]
    public DateTime? DataRegistro { get; set; }

    [Column("Data Desembaraço")]
    public DateTime? DataDesembaraço { get; set; }

    [Column("Unidade Desembaraço")]
    public string? URF { get; set; }

    [Column("Razão Social")]
    public string? RazaoSocial { get; set; }

    [Column("CNPJ")]
    public string? CNPJ { get; set; }

    [Column("E-CAC")]
    public string? ECac { get; set; }

    [Column("DOSSIE")]
    public string? Dossie { get; set; }
}
