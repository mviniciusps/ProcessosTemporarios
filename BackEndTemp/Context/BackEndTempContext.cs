using Microsoft.EntityFrameworkCore;
using Models;

namespace Context;

public class BackEndTempContext : DbContext
{
    public BackEndTempContext(DbContextOptions<BackEndTempContext> options) : base(options)
    {

    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        //VIEWS
        modelBuilder.Entity<ProcessosAtivos>()
            .HasNoKey()
            .ToView("vTelaPrincipalAtivos");

        modelBuilder.Entity<ProcessosArquivados>()
            .HasNoKey()
            .ToView("vTelaPrincipalArquivados");

        //FUNCTIONS
        modelBuilder.Entity<InformacoesPorProcesso>().HasNoKey();

        modelBuilder.Entity<ContratosPorProcesso>().HasNoKey();

        modelBuilder.Entity<InformacoesGeraisPorProrrogacao>().HasNoKey();

        modelBuilder.Entity<InformacoesGeraisPorProrrogacaoSegundoQuadro>().HasNoKey();

        modelBuilder.Entity<InformacoesGeraisTodasProrrogacoesPorProcesso>().HasNoKey();

        modelBuilder.Entity<IdPrincipal>().HasNoKey();
    }

    //VIEWS
    public DbSet<ProcessosAtivos> processosAtivos { get; set; }
    public DbSet<ProcessosArquivados> processosArquivados { get; set; }

    //FUNCTIONS
    public DbSet<InformacoesPorProcesso> informacoesPorProcessos { get; set; }
    public DbSet<ContratosPorProcesso> contratosPorProcesso { get; set; }
    public DbSet<InformacoesGeraisPorProrrogacao> informacoesGeraisPorProrrogacao { get; set; }
    public DbSet<InformacoesGeraisPorProrrogacaoSegundoQuadro> informacoesGeraisPorProrrogacaoSegundoQuadro { get; set; }
    public DbSet<InformacoesGeraisTodasProrrogacoesPorProcesso> informacoesGeraisTodasProrrogacoesPorProcesso { get; set; }
}