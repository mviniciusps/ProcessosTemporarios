using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models;

public class InserirDados
{
    public string? PaisNome { get; set; }
    public string? NomeCidadeExterior { get; set; }
    public string? NomeModal { get; set; }
    public string? EstadoNomeRecinto { get; set; }
    public string? CidadeNomeRecinto { get; set; }
    
    [StringLength(8)]
    public string? CepRecinto { get; set; }
    public string? NomeLogradouroRecinto { get; set; }
    public string? BairroLogradouroRecinto { get; set; }
    public string? EstadoNomeCnpj { get; set; }
    public string? CidadeNomeCnpj { get; set; }

    [StringLength(8)]
    public string? CepCnpj { get; set; }
    public string? NomeLogradouroCnpj { get; set; }
    public string? BairroLogradouroCnpj { get; set; }

    [StringLength(14)]
    public string? Cnpj { get; set; }
    public string? NomeEmpresa { get; set; }
    public string? NumeroApolice { get; set; }
    public DateTime? VencimentoGarantia { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? ValorSegurado { get; set; }

    [StringLength(15)]
    public string? NumeroCe { get; set; }
    public string? StatusCe { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? ValorAfrmmSuspenso { get; set; }
    public string? ConhecimentoEmbarque { get; set; }
    public DateTime? DataEmbarque { get; set; }
    public DateTime? DataChegada { get; set; }
    public string? NomeRegimeAduaneiro { get; set; }
    public DateTime? DataRegistro { get; set; }
    public string? NomeRecinto { get; set; }

    [StringLength(7)]
    public string? NumeroRecintoAduaneiro { get; set; }
    public string? NomeUnidadeReceitaFederal { get; set; }

    [StringLength(7)]
    public string? UnidadeReceitaFederal { get; set; }
    public string? Descricao { get; set; }

    [MinLength(10)]
    [MaxLength(12)]
    public string? NumeroDeclaracao { get; set; }

    [StringLength(15)]
    public string? NumeroDossie { get; set; }

    [StringLength(17)]
    public string? NumeroProcessoAdministrativo { get; set; }
    public DateTime? DataDesembaraco { get; set; }
    public string? NomeContratoAdmissao { get; set; }
    public DateTime? ContratoDataAssinaturaAdmissao { get; set; }
    public DateTime? ContratoVencimentoAdmissao { get; set; }
    public string? ContratoTipoAdmissao { get; set; }
    public string? NomeContratoPrestacaoServico { get; set; }
    public DateTime? ContratoDataAssinaturaPrestacaoServico { get; set; }
    public DateTime? ContratoVencimentoPrestacaoServico { get; set; }
    public string? ContratoTipoPrestacaoServico { get; set; }

    [StringLength(13)]
    public string? ReferenciaBraslog { get; set; }
    public string? ReferenciaCliente { get; set; }
}