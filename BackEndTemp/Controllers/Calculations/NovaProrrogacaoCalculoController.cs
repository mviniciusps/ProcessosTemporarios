using Context;
using Microsoft.AspNetCore.Mvc;

namespace Functions;

[ApiController]
[Route("[controller]")]
public class NovaProrrogacaoCalculoController : ControllerBase
{
    private readonly BackEndTempContext _context;

    public NovaProrrogacaoCalculoController(BackEndTempContext context)
    {
        _context = context;
    }

    //Recupera dias, meses, data (qual esteja preenchido)
    //Faz o calculo de meses (inteiro)
    //Recupera o total dos tributos (II, IPI, PIS, COFINS, ICMS)
    //Calcula o percentual sobre cada tributo (tela)
    //Recupera a taxa selic acumulada (tela)
    //Calcula o juros dos tributos (tela)
    //Calcula o total suspenso (tela)
    //Recupera Frete, Seguro, THC, Despesas, Adiçoes, TUM(bool), Taxas de conversão 
}