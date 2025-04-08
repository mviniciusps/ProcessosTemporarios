using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class ViewContrato
{
    [Column("Processo")]
    public string? ReferenciaBraslog { get; set; }

    [Column("Número Prorrogação")]
    public int? NumeroProrrogacao { get; set; }

    [Column("Data da Assinatura")]
    public DateTime? DataAssinatura { get; set; }

    [Column("Vencimento Contrato")]
    public DateTime? Vencimento { get; set; }
}
