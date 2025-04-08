using System;
using System.ComponentModel.DataAnnotations;//utilizar as notaçoes [Column] e [Key]
using System.ComponentModel.DataAnnotations.Schema;
public class ViewApoliceSeguroGarantia
{
    [Column("Referência Braslog")]
    public string? ReferenciaBraslog { get; set; }

    [Column("Número Apólice")]
    public string? NumeroApolice { get; set; }

    [Column("Vencimento Apólice")]
    public DateTime VencimentoApolice { get; set; }

    [Column("Recinto Alfandegado")]
    public string? RecintoAlfandegado { get; set; } //lê e ja atribui o valor na variavel
}