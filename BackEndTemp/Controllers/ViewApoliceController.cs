using Microsoft.AspNetCore.Mvc; //sem isso nao consegue usar [ApiController], etc
using Microsoft.EntityFrameworkCore; //conversa com o banco de dados
using WebApi.Models; //importa a classe dentro da pasta Models

namespace BackEndTemp.Controllers
{
    [Route("api/[controller]")] //API vai usar esse endereço, o controller vai ser o nome da classe
    [ApiController] //indica que esse controller é uma API, terá rotas e verbos
    public class ViewApoliceController : ControllerBase //cria uma clase que herda de ControllerBase, para utilizar os métodos
    {
        private readonly ProcessosTemporariosDBContext _context; //variavel do tipo ProcessosTemporariosDBContext, que é o contexto do banco de dados, criado por mim, e poder utilizar os métodos dele

        public ViewApoliceController(ProcessosTemporariosDBContext context)
        {
            _context = context;
        }

        // GET: api/ViewApolice
        [HttpGet] //endpoint
        public async Task<ActionResult<IEnumerable<ViewApoliceSeguroGarantia>>> GetViewApolices() //chamado quando alguem acessar o verbo
        //async marca o método como assíncrono
        //ActionResult é a resposta do verbo (200, etc)
        //IEnumerable é uma lista sem indicar o tipo
        //Task tipo de retorno que representa o processo assíncrono
        {
            return await _context.VApolices.ToListAsync();
        }
    }
}