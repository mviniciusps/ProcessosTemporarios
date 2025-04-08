import { Component, OnInit } from '@angular/core';
import { Dados } from '../shared/dados.model';
import { dados } from './dados-mock';
import { TabelaDadosService } from './tabela-dados.service'; // Importação do serviço

@Component({
  selector: 'app-tabela-dados',
  templateUrl: './tabela-dados.component.html',
  styleUrls: ['./tabela-dados.component.css'],
})

export class TabelaDadosComponent {

  public colunasTabela = [
    { titulo: 'Cliente', campo: 'nomeCliente' },
    { titulo: 'DI', campo: 'declaracaoImportacao' },
    { titulo: 'Processo', campo: 'referenciaBraslog' },
    // { titulo: 'AFRMM Tipo', campo: 'afrmmTipo' },
    //{ titulo: 'Número CE', campo: 'numeroCeMercante' },
    { titulo: 'Prazo', campo: 'prazoSolicitado', tipo: 'date' },
    //{ titulo: 'Registro', campo: 'dataRegistro' },
    //{ titulo: 'Desembaraço', campo: 'dataDesembaraço' },
    //{ titulo: 'URF', campo: 'urf' },
    //{ titulo: 'CNPJ', campo: 'cnpj' },
    //{ titulo: 'E-CAC', campo: 'eCac' },
    //{ titulo: 'Dossiê', campo: 'dossie' }
  ];

  public dadosDeclaracao: any[] = [];

  constructor(private service: TabelaDadosService) {
    this.service.getDados().subscribe((dados) => {
      this.dadosDeclaracao = dados;
    });
  }
}
