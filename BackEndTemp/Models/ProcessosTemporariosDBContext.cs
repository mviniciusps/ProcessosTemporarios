using Microsoft.EntityFrameworkCore;

//ponte entre o banco de dados e o controller, faz o CRUD no banco
namespace WebApi.Models
{
    public class ProcessosTemporariosDBContext : DbContext // herda DbContext permite usar os metodos
    {
        public ProcessosTemporariosDBContext(DbContextOptions<ProcessosTemporariosDBContext> options)//options do tipo DbContextOptions<generico>
            : base(options) //construtor da classe pai DbContext
        {
        }

        public DbSet<ViewApoliceSeguroGarantia> VApolices { get; set; } = null!;
        //DbSet (do tipo generico que representa uma tabela)
        //null! = evita avisos de valores nulos, o EF nao permite nulos
        public DbSet<ViewCeMercante> VMercante { get; set; } = null!;
        public DbSet<ViewCNPJ> VCNPJ { get; set; } = null!;
        public DbSet<ViewContrato> VContrato { get; set; } = null!;
        public DbSet<ViewDeclaracao> VDeclaracao { get; set; } = null!;
        public DbSet<ViewRecintoAlfandegado> VRecinto { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        //metodo herdado de DBContext, e subscrito da classe pai
        //protected é acessado apenas na classe e nas classes filhas
        //parametro do tipo modelBuilder
        {
            modelBuilder.Entity<ViewApoliceSeguroGarantia>()//configura a entidade (model que contem as tabelas)
                .HasNoKey() //nao tem chave primaria
                .ToView("vApoliceSeguroGarantia"); // informa que a entidade vem de uma view, nome exato da VIEW no banco

            modelBuilder.Entity<ViewCeMercante>()
                .HasNoKey()
                .ToView("vCeMercante");

            modelBuilder.Entity<ViewCNPJ>()
                .HasNoKey()
                .ToView("vCNPJ");

            modelBuilder.Entity<ViewContrato>()
                .HasNoKey()
                .ToView("vContrato");

            modelBuilder.Entity<ViewDeclaracao>()
                .HasNoKey()
                .ToView("vDeclaracao");

            modelBuilder.Entity<ViewRecintoAlfandegado>()
                .HasNoKey()
                .ToView("vRecintoAlfandegado");
        }
    }
}