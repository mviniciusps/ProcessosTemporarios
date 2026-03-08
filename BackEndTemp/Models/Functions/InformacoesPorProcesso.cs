namespace Models;

public class InformacoesPorProcesso
{
    public int IdCnpj { get; set; }
    public string? CNPJ { get; set; }
    public string? RazaoSocial { get; set; }
    public string? RecintoAduaneiro { get; set; }
    public string? URF { get; set; }
    public string? Declaracao { get; set; }
    public DateTime? DataRegistroDeclaracao { get; set; }
    public string? ConhecimentoEmbarque { get; set; }
    public DateTime? DataChegadaBrasil { get; set; }
    public string? CEMercante { get; set; }

    public decimal? PesoLiquido { get; set; }
    public string? CidadeEmbarque { get; set; }
    public string? Dossie { get; set; }
    public string? ECAC { get; set; }
}