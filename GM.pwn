//----------------------------------------------------------
//
//  CIDADE ROLEPLAY  1.0 [ CI:RP ] ( OpenSource )
//  A gamemode programmed by _Gamer8 ( Input ).
//
//  ANOTAÇÕES:
//  1ª- Criar um taximetro logo.
//
//----------------------------------------------------------
#include <a_samp>
#include <dof2>
#include <sscanf>
#include <zcmd>
//----------------------------------------------------------
//
//  Variaveis e Definições
//
//----------------------------------------------------------
#define SetPlayerPosEx(%0,%1,%2,%3,%4) SetPlayerPos(%0,%1,%2,%3) , SetPlayerFacingAngle(%0,%4)
#define CallBack::%0(%1) %0(%1); public %0(%1)

#define MAX_ROTAS                   ( 50 )
#define DIRETORIO_CAMINHONEIRO      "Empregos/Caminhoneiro"

#define Amarelo     			 0xFFFF00AA
#define Branco      			 0xFFFFFFAA
#define Cinza       			 0xC0C0C0AA
#define COLOR_FADE1              0xE6E6E6E6
#define COLOR_FADE2 	         0xC8C8C8C8
#define COLOR_FADE3              0xAAAAAAAA
#define COLOR_FADE4              0x8C8C8C8C
#define COLOR_FADE5              0x6E6E6E6E
#define COLOR_PURPLE             0xC2A2DAAA
#define Amarelo2	             0xF5DEB3AA
#define AzulBB                   0xCCCCFFFF
#define Aviso                    0xFF6347AA

enum // Dialog's.
{
    DIALOG_NULL,
	DIALOG_LOGIN,
	DIALOG_REGISTRO,
	DIALOG_SERVICO,
	DIALOG_TELEPORT,
	DIALOG_BUY_247,
	DIALOG_BUY_PIZZARIA
};
enum // Empregos
{
	DESEMPREGADO,
	CAMINHONEIRO,
	TAXISTA
};
enum rInfo
{
	rNome[50],
	rCarga[50],
	rValor,
	rExp,
	rID,
	rBloqueio,
	rTempo,
	Float: rX,
	Float: rY,
	Float: rZ
};
new rDados[MAX_ROTAS][rInfo];
enum pInfo
{
	Admin,
	Skin,
	Dinheiro,
	Cigarros,
	Camisinha,
	Cereal,
	Emprego
};
new pDados[MAX_PLAYERS][pInfo];
new RotaID[MAX_PLAYERS];
new Text: Interface[5];
new bool: EmServico[MAX_PLAYERS];
new bool: Logado[MAX_PLAYERS];
new bool: IsPlayerInDave[MAX_PLAYERS];
new Timer_PlayerUpdate;
new Timer_Random;
new Veiculo_Truck[6];
new Carga_Truck[5];
new Veiculo_Taxistas[10];

new bool:Taxistas_EmCorrida[MAX_PLAYERS];
new Taxistas_CorridaPreco[MAX_PLAYERS];
new Passageiro_Tempo[MAX_PLAYERS];
new Passageiro_Preco[MAX_PLAYERS];

new MensagensRandom[][128] = {
	{"[ CidadeRP ]: Quer anunciar seu site aqui? Entre em contato com nossa equipe via fórum!"},
	{"[ CidadeRP ]: Este servidor é totalmente OpenSource! Seu código de fonte está dísponivel na internet."},
	{"[ CidadeRP ]: Está afim de se comunicar com a administração? Então use /ask!"},
	{"[ CidadeRP ]: Não sabe os comandos do servidor? Então use /ajuda."}
};
//----------------------------------------------------------
//
//  Callbacks e Main()
//
//----------------------------------------------------------
main()
{
	SendRconCommand("hostname [CidadeRP] v1.0");
	SendRconCommand("mapname San Andreas");
	SetGameModeText("BR/PT©");
	UsePlayerPedAnims();
	DisableInteriorEnterExits();
	ShowPlayerMarkers(false);
	ConnectNPC("Dave","pizzaria_atendente");

	for(new i = 0; i < MAX_PLAYERS; ++ i)
	{
		Timer_PlayerUpdate = SetTimerEx("PlayerUpdate", 1000, true, "u", i);
	}
	Timer_Random = SetTimer("Mensagem_Random", 20*60000, true);

	// Rotas Caminhoneiros:
	new file[70];
	new file2[70];
	format(file2, sizeof file2, "%s/ultimo.ini", DIRETORIO_CAMINHONEIRO);
	if(!DOF2_FileExists(file2))
	{
		DOF2_CreateFile(file2);
		DOF2_SetInt(file2, "Ultimo ID", 0);
		DOF2_SaveFile();
	}
	for(new i = 0; i < DOF2_GetInt(file2, "Ultimo ID"); ++ i)
	{
		format(file, sizeof file, "%s/ROTA_%d.ini", DIRETORIO_CAMINHONEIRO, i);
		strmid(rDados[i][rNome], DOF2_GetString(file, "Nome"), 0, strlen( DOF2_GetString(file, "Nome") ), 255);
		rDados[i][rCarga] = DOF2_GetInt(file, "Carga");

		rDados[i][rX] = DOF2_GetFloat(file, "X");
		rDados[i][rY] = DOF2_GetFloat(file, "Y");
		rDados[i][rZ] = DOF2_GetFloat(file, "Z");

		rDados[i][rValor] 	 = DOF2_GetInt(file, "Valor");
		rDados[i][rExp]   	 = DOF2_GetInt(file, "Exp");
		rDados[i][rID]    	 = DOF2_GetInt(file, "ID");
		rDados[i][rBloqueio] = DOF2_GetInt(file, "Bloqueio");
		rDados[i][rTempo]    = DOF2_GetInt(file, "Tempo");
	}
	// Fim das Rotas.

	Interface[0] = TextDrawCreate(36.000000, 402.000000, "Cidade~b~RP");
	TextDrawBackgroundColor(Interface[0], 255);
	TextDrawFont(Interface[0], 1);
	TextDrawLetterSize(Interface[0], 0.700000, 3.000000);
	TextDrawColor(Interface[0], -1);
	TextDrawSetOutline(Interface[0], 1);
	TextDrawSetProportional(Interface[0], 1);

	Interface[1] = TextDrawCreate(495.000000, 97.000000, "00:00:00 00/00/0000");
	TextDrawBackgroundColor(Interface[1], 255);
	TextDrawFont(Interface[1], 1);
	TextDrawLetterSize(Interface[1], 0.300000, 1.000000);
	TextDrawColor(Interface[1], -1);
	TextDrawSetOutline(Interface[1], 0);
	TextDrawSetProportional(Interface[1], 1);
	TextDrawSetShadow(Interface[1], 1);
	
	Interface[2] = TextDrawCreate(535.000000, 404.000000, "OPENSOURCE");
	TextDrawBackgroundColor(Interface[2], 255);
	TextDrawFont(Interface[2], 3);
	TextDrawLetterSize(Interface[2], 0.500000, 3.000000);
	TextDrawColor(Interface[2], -1);
	TextDrawSetOutline(Interface[2], 1);
	TextDrawSetProportional(Interface[2], 1);

	Interface[3] = TextDrawCreate(535.000000, 400.000000, "Servidor");
	TextDrawBackgroundColor(Interface[3], 255);
	TextDrawFont(Interface[3], 1);
	TextDrawLetterSize(Interface[3], 0.230000, 0.999999);
	TextDrawColor(Interface[3], -1);
	TextDrawSetOutline(Interface[3], 1);
	TextDrawSetProportional(Interface[3], 1);

	Interface[4] = TextDrawCreate(542.000000, 430.000000, "github.com/4gamer8/Cidade-Roleplay");
	TextDrawBackgroundColor(Interface[4], 255);
	TextDrawFont(Interface[4], 1);
	TextDrawLetterSize(Interface[4], 0.180000, 1.000000);
	TextDrawColor(Interface[4], -1);
	TextDrawSetOutline(Interface[4], 1);
	TextDrawSetProportional(Interface[4], 1);

	AddStaticPickup(1318, 23, -2442.7583, 754.9297, 35.1719, -1); // 24/7 San Fierro
	AddStaticPickup(1318, 23, -25.884498, -185.868988, 1003.546875, -1);

	AddStaticPickup(1239, 23, -29.8000, -185.1145, 1003.5469, -1); // Menu de Compras.

	AddStaticPickup(1318, 23, -1808.7319, 945.8968, 24.8906, -1); // Well stacked pizza
	AddStaticPickup(1318, 23, 372.2366, -133.4248, 1001.4922, -1);

	Create3DTextLabel("24/7 ( San Fierro )\nPrecione 'F' para entrar.", AzulBB, -2442.7583, 754.9297, 35.1719, 10.0, 0);
	Create3DTextLabel("Menu de Compras\nPrecione 'F' para utilizar.", AzulBB, -29.8000, -185.1145, 1003.5469, 10.0, 0);

	Create3DTextLabel("Well Stacked Pizza\nPrecione 'F' para entrar.", AzulBB, -1808.7319, 945.8968, 24.8906, 10.0, 0);

	// Veículos Truck / Cargas:
	Veiculo_Truck[ 0 ] = AddStaticVehicle(403,-1707.0216,25.9880,4.1621,225.4480,0,0);  // Veículo Truck
	Veiculo_Truck[ 1 ] = AddStaticVehicle(403,-1710.3644,22.5754,4.1634,225.0118,0,0);  // Veículo Truck
	Veiculo_Truck[ 2 ] = AddStaticVehicle(403,-1713.6165,19.3848,4.1886,224.2663,0,0);  // Veículo Truck
	Veiculo_Truck[ 3 ] = AddStaticVehicle(403,-1717.1411,15.8486,4.2074,224.0666,0,0);  // Veículo Truck
	Veiculo_Truck[ 4 ] = AddStaticVehicle(403,-1574.7745,136.9959,4.1609,135.1343,0,0); // Veículo Truck
	Veiculo_Truck[ 5 ] = AddStaticVehicle(403,-1570.9988,133.1734,4.1604,134.2876,0,0); // Veículo Truck

	Carga_Truck[ 0 ] = AddStaticVehicle(584,-1543.1298,146.4400,3.5547,135.0835,0,0); // Carga Truck
	Carga_Truck[ 1 ] = AddStaticVehicle(584,-1557.8564,132.6670,3.5547,133.0835,0,0); // Carga Truck
	Carga_Truck[ 2 ] = AddStaticVehicle(584,-1571.5835,119.8292,3.5547,133.0835,0,0); // Carga Truck
	Carga_Truck[ 3 ] = AddStaticVehicle(584,-1567.6138,115.5345,3.5547,135.0835,0,0); // Carga Truck
	Carga_Truck[ 4 ] = AddStaticVehicle(584,-1560.6224,108.4390,3.5547,135.0835,0,0); // Carga Truck

	// Veículos Taxistas:
	Veiculo_Taxistas[0] = AddStaticVehicle(420,-1989.7920,101.9025,27.3220,88.4901,6,6); // Taxi
	Veiculo_Taxistas[1] = AddStaticVehicle(420,-1989.7920,106.3374,27.3207,91.2644,6,6); // Taxi
	Veiculo_Taxistas[2] = AddStaticVehicle(420,-1989.7920,110.7141,27.3180,91.3888,6,6); // Taxi
	Veiculo_Taxistas[3] = AddStaticVehicle(420,-1989.7920,115.1436,27.3396,90.9307,6,6); // Taxi
	Veiculo_Taxistas[4] = AddStaticVehicle(420,-1989.7920,119.8499,27.3193,90.1138,6,6); // Taxi
	Veiculo_Taxistas[5] = AddStaticVehicle(420,-1989.7920,179.9578,27.3177,89.5232,6,6); // Taxi
	Veiculo_Taxistas[6] = AddStaticVehicle(420,-1989.7920,184.0076,27.3193,90.2048,6,6); // Taxi
	Veiculo_Taxistas[7] = AddStaticVehicle(420,-1989.7920,187.9897,27.3196,90.3754,6,6); // Taxi
	Veiculo_Taxistas[8] = AddStaticVehicle(420,-1989.7920,195.1254,27.3194,90.9561,6,6); // Taxi
	Veiculo_Taxistas[9] = AddStaticVehicle(420,-1989.7920,191.7501,27.3184,89.5410,6,6); // Taxi
	return true;
}
public OnGameModeExit()
{
    KillTimer(Timer_PlayerUpdate);
    KillTimer(Timer_Random);
    DOF2_Exit();
    return true;
}
public OnPlayerConnect(playerid)
{
	new file[70];
	RotaID[playerid] = 555;
	format(file, sizeof file, "Contas/%s.ini", Nome(playerid));

	for(new i = 0; i < 100; ++i)
	{
	    SendClientMessage(playerid, Branco, " ");
	}
    
	EmServico[playerid] 			= false;
	Logado[playerid] 				= false;
	IsPlayerInDave[playerid]    	= false;
	Taxistas_EmCorrida[playerid]	= false;
	Taxistas_CorridaPreco[playerid]	= 0;
	Passageiro_Tempo[playerid]		= 0;
	Passageiro_Preco[playerid]		= 0;
	
	if(!IsPlayerNPC(playerid))
	{
		if(DOF2_FileExists(file))
		    return ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "..:: Efetuando Login ::..", "Seja bem vindo ao CidadeRP!\nEsta conta está registrada em nosso banco de dados..\nDigite abaixo a sua senha:", "Entrar", "Sair");
		else if(!DOF2_FileExists(file))
		    return ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD, "..:: Efetuando Cadastro ::..", "Seja bem vindo ao CidadeRP!\nEsta conta não está registrada em nosso banco de dados..\nDigite abaixo a sua senha:", "Cadastrar", "Sair");

		SendClientMessage(playerid, Amarelo, "» SEJA BEM VINDO AO CIDADE ROLEPLAY v1.0! «");
	}
	return true;
}
public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}
public OnPlayerDisconnect(playerid, reason)
{
	if(Logado[playerid])
	{
	    SalvarConta(playerid);
	}
	return true;
}
public OnPlayerSpawn(playerid)
{
	if(!IsPlayerNPC(playerid) && !Logado[playerid]) return Kick(playerid);
	SetPlayerSkin(playerid, pDados[playerid][Skin]);
	SetPlayerPosEx(playerid, -1969.2827, 138.2147, 27.6875, 80.9905);
	RemovePlayerAttachedObject(playerid, 1);
	SetPlayerAttachedObject(playerid, 1, 3026, 1, -0.16, -0.08, 0.0, 0.5, 0.5, 0.0);
	if(pDados[playerid][Admin] > 0 && !EmServico[playerid])
	{
	    ShowPlayerDialog(playerid, DIALOG_SERVICO, DIALOG_STYLE_MSGBOX, "Deseja respawnar em modo serviço?", "Olá administrador!\nVejo que você respawnou em modo jogo, deseja ativar o modo administrador?", "Sim", "Não");
	}
	if(IsPlayerNPC(playerid))
	{
		RemovePlayerAttachedObject(playerid, 1);
	    if(!strcmp(Nome(playerid), "Dave", true))
	    {
			new Text3D:label = Create3DTextLabel("Para falar com o Dave\ndigite '{000099}Olá Dave{008080}'.", 0x008080FF, 0.0, 0.0, 0.0, 10.0, 0);
    		Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, -3.0);
	        SetPlayerSkin(playerid, 155);
	        SetPlayerPosEx(playerid, 373.5948, -117.2784, 1001.4995, 182.0252);
		}
	}
	return true;
}
public OnPlayerText(playerid, text[])
{
    new string[128];
    new Dialog[500];
    new Float: p[3];
    GetPlayerPos(playerid, p[0], p[1], p[2]);
    format(string, sizeof(string), "[IC] %s diz: %s", Nome(playerid), text);
    for(new chat; chat < MAX_PLAYERS; chat++)
    {
		if(IsPlayerInRangeOfPoint(playerid, 10.0, p[0], p[1], p[2]))
        {
        	SendClientMessage(playerid, -1, string);
        }
  	}
	if(IsPlayerInRangeOfPoint(playerid, 2.0, 373.6989, -118.8050, 1001.4922)) // Cardapio.
	{
		if(IsPlayerInDave[playerid])
		{
		    if(!strcmp(text, "Sim", true) || !strcmp(text, "sim", true))
		    {
			   	format(string, sizeof string, "[IC] Dave diz: Aqui esta Sr.%s.", Nome(playerid));
			    for(new chat; chat < MAX_PLAYERS; chat++)
			    {
					if(IsPlayerInRangeOfPoint(playerid, 10.0, p[0], p[1], p[2]))
			        {
			        	SendClientMessage(playerid, -1, string);
			        }
			  	}
				strcat(Dialog, "[PIZZA] Portuguesa [PEQUENA]. - $15.00\n");
				strcat(Dialog, "[PIZZA] Portuguesa [MEDIA]. - $20.00\n");
				strcat(Dialog, "[PIZZA] Portuguesa [GRANDE]. - $25.00\n");
				strcat(Dialog, "[PIZZA] 4 Queijos [PEQUENA]. - $15.00\n");
				strcat(Dialog, "[PIZZA] 4 Queijos [MEDIA]. - $20.00\n");
				strcat(Dialog, "[PIZZA] 4 Queijos [GRANDE]. - $25.00\n");
				strcat(Dialog, "[PIZZA] Calabresa com Catupiry [PEQUENA]. - $25.00\n");
				strcat(Dialog, "[PIZZA] Calabresa com Catupiry [MEDIA]. - $30.00\n");
				strcat(Dialog, "[PIZZA] Calabresa com Catupiry [GRANDE]. - $35.00\n");
				ShowPlayerDialog(playerid, DIALOG_BUY_PIZZARIA, DIALOG_STYLE_LIST, "Cardapio:", Dialog, "Selecionar", "Fechar");
				IsPlayerInDave[playerid] = false;
				return false;
		    }
		    else if(!strcmp(text, "Não", true) || !strcmp(text, "não", true))
		    {
			   	format(string, sizeof string, "[IC] Dave diz: Ok Sr. Volte sempre!");
			    for(new chat; chat < MAX_PLAYERS; chat++)
			    {
					if(IsPlayerInRangeOfPoint(playerid, 10.0, p[0], p[1], p[2]))
			        {
			        	SendClientMessage(playerid, -1, string);
			        }
			  	}
		        IsPlayerInDave[playerid] = false;
				return false;
			}
			else
			{
			   	format(string, sizeof string, "[IC] Dave diz: Desculpe Sr.%s, não compreendi sua resposta.", Nome(playerid));
			    for(new chat; chat < MAX_PLAYERS; chat++)
			    {
					if(IsPlayerInRangeOfPoint(playerid, 10.0, p[0], p[1], p[2]))
			        {
			        	SendClientMessage(playerid, -1, string);
			        }
			  	}
				return false;
			}
	   	}
		else if(!IsPlayerInDave[playerid])
		{
			if(!strcmp(text, "Ola Dave", true) || !strcmp(text, "Iae Dave", true) || !strcmp(text, "Olá Dave", true))
			{
			   	format(string, sizeof string, "{FFFFFF}[IC] Dave diz: Olá %s, em que posso ajuda-lo? Deseja um cardapio? Digite {000099}Sim{FFFFFF} ou {000099}Não", Nome(playerid));
			    for(new chat; chat < MAX_PLAYERS; chat++)
			    {
					if(IsPlayerInRangeOfPoint(playerid, 10.0, p[0], p[1], p[2]))
			        {
			        	SendClientMessage(playerid, -1, string);
			        }
			  	}
			    IsPlayerInDave[playerid] = true;
			}
		}
	}
    return false;
}
public OnPlayerStateChange(playerid, newstate, oldstate)
{
	new vehicleid = GetPlayerVehicleID(playerid);
	if(newstate == PLAYER_STATE_DRIVER)
	{
	    if(NoTaxi(vehicleid))
		{
		    if(pDados[playerid][Emprego] != TAXISTA)
		    {
		        RemovePlayerFromVehicle(playerid);
		        SendClientMessage(playerid, Cinza, "[CI:RP]: Você não é um taxista.");
			}
		}
	    if(NoCaminhao(vehicleid))
		{
		    if(pDados[playerid][Emprego] != CAMINHONEIRO)
		    {
		        RemovePlayerFromVehicle(playerid);
		        SendClientMessage(playerid, Cinza, "[CI:RP]: Você não é um caminhoneiro.");
			}
		}
	}
	return true;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == 16)
	{
	    if(IsPlayerInRangeOfPoint(playerid, 2.0, -2442.7583, 754.9297, 35.1719)) // Entrada 24/7 San Fierro.
	    {
	        SetPlayerPos(playerid, -25.884498, -185.868988, 1003.546875);
	        SetPlayerInterior(playerid, 17);
	        GameTextForPlayer(playerid, "24/7", 500, 1);
		}
	    if(IsPlayerInRangeOfPoint(playerid, 2.0, -25.884498, -185.868988, 1003.546875)) // Saída 24/7 San Fierro.
	    {
	        SetPlayerPos(playerid, -2442.7583, 754.9297, 35.1719);
	        SetPlayerInterior(playerid, 0);
	        GameTextForPlayer(playerid, "San Fierro", 500, 1);
		}
	    if(IsPlayerInRangeOfPoint(playerid, 2.0, -1808.7319, 945.8968, 24.8906)) // Entrada Well stacked pizza
	    {
	        SetPlayerPos(playerid, 372.2366, -133.4248, 1001.4922);
	        SetPlayerInterior(playerid, 5);
	        GameTextForPlayer(playerid, "Well stacked pizza", 500, 1);
		}
	    if(IsPlayerInRangeOfPoint(playerid, 2.0, 372.2366, -133.4248, 1001.4922)) // Saída Well stacked pizza.
	    {
	        SetPlayerPos(playerid, -1808.7319, 945.8968, 24.8906);
	        SetPlayerInterior(playerid, 0);
	        GameTextForPlayer(playerid, "San Fierro", 500, 1);
		}
		if(IsPlayerInRangeOfPoint(playerid, 2.0, -29.8000, -185.1145, 1003.5469)) // Menu de Compras.
		{
		    new Dialog[500];
		    strcat(Dialog, "Box de Cigarros[20 u.] - $7.00\n");
		    strcat(Dialog, "Camisinha[1 u.] - FREE\n");
		    strcat(Dialog, "Camisinhas Jontex[7 u.] - $2.00\n");
		    strcat(Dialog, "Barra de Cereal[1 u.] - $1.00\n");
		    ShowPlayerDialog(playerid, DIALOG_BUY_247, DIALOG_STYLE_LIST, "Menu de Compras", Dialog, "Comprar", "Fechar");
		}
	}
	return true;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch( dialogid )
	{
	    case DIALOG_REGISTRO:
		{
		    if(!response) return Kick(playerid);
		    if(response) return CriarConta(playerid, Nome(playerid), inputtext);
		}
	    case DIALOG_LOGIN:
		{
		    if(!response) return Kick(playerid);
		    if(response) return CarregarConta(playerid, inputtext);
		}
		case DIALOG_SERVICO:
		{
		    if(!response) return false;
		    if(response) return cmd_servico(playerid);
		}
		case DIALOG_TELEPORT:
		{
		    if(!response) return false;
		    if(response)
		    {
		        switch( listitem )
		        {
		            case 0: // 24/7 ( San Fierro )
		            {
		                SetPlayerPos(playerid, -2442.7583, 754.9297, 35.1719);
		                SendClientMessage(playerid, Amarelo2, "» ( /irlocal ) « Você foi teleportado para a 24/7 ( San Fierro ).");
					}
		            case 1: // Well stacked pizza ( San Fierro )
		            {
		                SetPlayerPos(playerid, -1808.7319, 945.8968, 24.8906);
		                SendClientMessage(playerid, Amarelo2, "» ( /irlocal ) « Você foi teleportado para a Well stacked pizza ( San Fierro ).");
					}
				}
			}
		}
		case DIALOG_BUY_247:
		{
		    if(!response) return false;
		    if(response)
		    {
		        switch( listitem )
		        {
		            case 0: // Box de Cigarros - $7.00
		            {
		                pDados[playerid][Cigarros] += 20;
		                SendClientMessage(playerid, Amarelo2, "» Efetuada a compra de Box de Cigarros com sucesso! Custo: $7.00");
		                pDados[playerid][Dinheiro] -= 7;
						GivePlayerMoney(playerid, -7);
					}
		            case 1: // Camisinha - FREE
		            {
		                pDados[playerid][Camisinha] += 1;
		                SendClientMessage(playerid, Amarelo2, "» Efetuada a compra de uma Camisinha com sucesso! Custo: Gratis");
					}
		            case 2: // Camisinhas Jontex - $2.00
		            {
		                pDados[playerid][Camisinha] += 7;
		                SendClientMessage(playerid, Amarelo2, "» Efetuada a compra de Camisinhas Jontex com sucesso! Custo: $2.00");
		                pDados[playerid][Dinheiro] -= 2;
						GivePlayerMoney(playerid, -2);
					}
		            case 3: // Barra de Cereal - $1.00
		            {
		                pDados[playerid][Cereal] += 1;
		                SendClientMessage(playerid, Amarelo2, "» Efetuada a compra de Barra de Cereal com sucesso! Custo: $1.00");
		                pDados[playerid][Dinheiro] -= 1;
						GivePlayerMoney(playerid, -1);
					}
		        }
			}
		}
		case DIALOG_BUY_PIZZARIA:
		{
			if(!response) return false;
			if(response)
			{
			    switch( listitem )
			    {
		            case 0: //[PIZZA] Portuguesa [PEQUENA]. - $15.00
		            {
		                SendClientMessage(playerid, Amarelo2, "» Você comeu uma pizza Portuguesa [PEQUENA] no valor de $15,00");
		                GivePlayerMoney(playerid, -15);
		                pDados[playerid][Dinheiro] -= 15;
		            }
		            case 1: //[PIZZA] Portuguesa [MEDIA]. - $20.00
		            {
		                SendClientMessage(playerid, Amarelo2, "» Você comeu uma pizza Portuguesa [MEDIA] no valor de $20,00");
		                GivePlayerMoney(playerid, -20);
		                pDados[playerid][Dinheiro] -= 20;
		            }
		            case 2: //[PIZZA] Portuguesa [GRANDE]. - $25.00
		            {
		                SendClientMessage(playerid, Amarelo2, "» Você comeu uma pizza Portuguesa [GRANDE] no valor de $25,00");
		                GivePlayerMoney(playerid, -25);
		                pDados[playerid][Dinheiro] -= 25;
		            }
		            
		            case 3: //[PIZZA] 4 Queijos [PEQUENA]. - $15.00
		            {
		                SendClientMessage(playerid, Amarelo2, "» Você comeu uma pizza 4 Queijos [PEQUENA] no valor de $15,00");
		                GivePlayerMoney(playerid, -15);
		                pDados[playerid][Dinheiro] -= 15;
		            }
		            case 4: //[PIZZA] 4 Queijos [MEDIA]. - $20.00
		            {
		                SendClientMessage(playerid, Amarelo2, "» Você comeu uma pizza 4 Queijos [MEDIA] no valor de $20,00");
		                GivePlayerMoney(playerid, -20);
		                pDados[playerid][Dinheiro] -= 20;
		            }
		            case 5: //[PIZZA] 4 Queijos [GRANDE]. - $25.00
		            {
		                SendClientMessage(playerid, Amarelo2, "» Você comeu uma pizza 4 Queijos [GRANDE] no valor de $25,00");
		                GivePlayerMoney(playerid, -25);
		                pDados[playerid][Dinheiro] -= 25;
		            }
		            
		            case 6: //[PIZZA] Calabresa com Catupiry [PEQUENA]. - $25.00
		            {
		                SendClientMessage(playerid, Amarelo2, "» Você comeu uma pizza Calabresa com Catupiry [PEQUENA] no valor de $25,00");
		                GivePlayerMoney(playerid, -25);
		                pDados[playerid][Dinheiro] -= 25;
		            }
		            case 7: //[PIZZA] Calabresa com Catupiry [MEDIA]. - $30.00
		            {
		                SendClientMessage(playerid, Amarelo2, "» Você comeu uma pizza Calabresa com Catupiry [MEDIA] no valor de $30,00");
		                GivePlayerMoney(playerid, -30);
		                pDados[playerid][Dinheiro] -= 30;
		            }
		            case 8: //[PIZZA] Calabresa com Catupiry [GRANDE]. - $35.00
		            {
		                SendClientMessage(playerid, Amarelo2, "» Você comeu uma pizza Calabresa com Catupiry [GRANDE] no valor de $35,00");
		                GivePlayerMoney(playerid, -35);
		                pDados[playerid][Dinheiro] -= 35;
		            }
			    }
			}
		}
	}
	return true;
}
public OnPlayerUpdate(playerid)
{
	// Relogio:
	new date[3];
	new hour[3];
	new String[128];
	gettime(hour[0], hour[1], hour[2]);
	getdate(date[2], date[1], date[0]);
	format(String, sizeof String, " %02d:%02d:%02d %02d/%02d/%d", hour[0], hour[1], hour[2], date[0], date[1], date[2]);
	TextDrawSetString(Interface[1], String);
	return true;
}
CallBack::Mensagem_Random()
{
	new rand = random(sizeof MensagensRandom);
	SendClientMessageToAll(Aviso, MensagensRandom[rand]);
	return true;
}
CallBack::PlayerUpdate(playerid)
{
	new file[70];
	new String[128];
	format(file, sizeof file, "%s/ultimo.ini", DIRETORIO_CAMINHONEIRO);
	for(new i = 0; i < DOF2_GetInt(file, "Ultimo ID"); i++)
	{
		if(rDados[i][rBloqueio] == 1)
		{
		    rDados[i][rTempo] --;
		    if(rDados[i][rTempo] == 0)
		    {
		        format(String, sizeof String, "( Atenção Caminhoneiros ) A Rota %s acaba de ser liberada novamente!", i);
		        SendClientMessageToAll(Amarelo2, String);
		    }
		}
	}
	return true;
}
//----------------------------------------------------------
//
//  Comandos Gerais
//
//----------------------------------------------------------
COMMAND:admins(playerid, params[])
{
	new Nivel_Admin[16];
	new String[128];
	SendClientMessage(playerid, Amarelo2, "Administradores(as) online:");
	for(new i = 0; i < MAX_PLAYERS; ++i)
	{
	    switch( pDados[i][Admin] )
	    {
	        case 1: Nivel_Admin = "Beta Tester";
	        case 2: Nivel_Admin = "Moderador";
	        case 3: Nivel_Admin = "Administrador";
	        case 4: Nivel_Admin = "Supervisor";
	        case 5: Nivel_Admin = "Operador Master";
	        case 6: Nivel_Admin = "Desenvolvedor";
		}
		if( pDados[i][Admin] > 0 )
		{
		    format(String, sizeof String, "%s: %s [ID:%d] - %s", Nivel_Admin, Nome(i), i, EmServico[i] ? ("Em Serviço") : ("Fora de Serviço"));
		    SendClientMessage(playerid, Branco, String);
		}
	}
	return true;
}
COMMAND:taxistas(playerid, params[])
{
	new String[128];
	SendClientMessage(playerid, Amarelo2, "Taxistas online:");
	for(new i = 0; i < MAX_PLAYERS; ++i)
	{
		if(pDados[i][Emprego] == TAXISTA)
		{
		    format(String, sizeof String, "[Taxista]: %s Modo: %s.", Nome(i), Taxistas_EmCorrida[i] ? ("Em Serviço") : ("Fora de Serviço"));
		    SendClientMessage(playerid, Branco, String);
		}
	}
	return true;
}
COMMAND:status(playerid)
{
	new String[ 128 ];
	new Emprego_String[ 50 ];

	switch( pDados[playerid][Emprego] )
	{
	    case DESEMPREGADO: 	Emprego_String = "Desempregado";
	    case CAMINHONEIRO: 	Emprego_String = "Caminhoneiro";
	    case TAXISTA: 		Emprego_String = "Taxista";
	}

	SendClientMessage(playerid, Branco, "Suas informações:");
	format(String, sizeof String, "Nome: [%s] Dinheiro: [$%d] Skin ID: [%d] Emprego: [%s]", Nome(playerid), GetPlayerMoney(playerid), pDados[playerid][Skin], Emprego_String);
	SendClientMessage(playerid, COLOR_FADE1, String);
	format(String, sizeof String, "Camisinhas: [%d] Cigarros: [%d] Barras de Cereal: [%d]", pDados[playerid][Camisinha], pDados[playerid][Cigarros], pDados[playerid][Cereal]);
	SendClientMessage(playerid, COLOR_FADE2, String);
	return true;
}

COMMAND:me(playerid, params[])
{
	if(sscanf(params,"s[128]", params[0]))
	    return SendClientMessage(playerid, Cinza, "Comando: /me [ação]");
	new Float: p[3], String[128];
	GetPlayerPos(playerid, p[0], p[1], p[2]);
	format(String, sizeof String, "* %s %s.", Nome(playerid), params[0]);
    for(new chat; chat < MAX_PLAYERS; chat++)
		if(IsPlayerInRangeOfPoint(playerid, 10.0, p[0], p[1], p[2]))
			SendClientMessage(playerid, -1, String);
	return true;
}

COMMAND:ask(playerid, params[])
{
	new Pergunta[128];
	new String[128];
	if(sscanf(params,"s[128]",Pergunta))
		return SendClientMessage(playerid, Cinza, "Comando: /ask [pergunta]");

	for(new i = 0; i < MAX_PLAYERS; ++i)
	{
	    if( pDados[i][Admin] > 0 )
	    {
			format(String, sizeof String, "• Pergunta (/ask): %s [ID:%d] » %s.", Nome(playerid), playerid, Pergunta);
			SendClientMessage(i, Amarelo, String);
		}
	}

	SendClientMessage(playerid, Branco, "» Pergunta enviada para todos os administradores presentes.");
	SendClientMessage(playerid, Cinza, "Só use o /ask novamente caso demore muito a vir uma resposta.");
	return true;
}
COMMAND:fumar(playerid)
{
	if(!pDados[playerid][Cigarros])
	    return SendClientMessage(playerid, Cinza, "Você não tem cigarros.");
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
	pDados[playerid][Cigarros] --;
	cmd_me(playerid, "acendeu um dos seus cigarros");
	return true;
}
COMMAND:ajuda(playerid)
{
	SendClientMessage(playerid, COLOR_FADE1, " ");
	SendClientMessage(playerid, Branco, "Comuns: /admins /taxistas /ask /status.");
	SendClientMessage(playerid, Branco, "Ações: /me /fumar.");
	if(pDados[playerid][Emprego] == CAMINHONEIRO)
	{
	    SendClientMessage(playerid, Branco, "Emprego: /rotas /pegarrota /entregar.");
	}
	if(pDados[playerid][Emprego] == TAXISTA)
	{
	    SendClientMessage(playerid, Branco, "Emprego: /taximetro /encerrar.");
	}
	SendClientMessage(playerid, COLOR_FADE1, " ");
	return true;
}
//----------------------------------------------------------
//  Comandos dos Empregos: Caminhoneiro.
//----------------------------------------------------------
COMMAND:entregar(playerid)
{
	new String[128];
	if(RotaID[playerid] == 555)
	    return SendClientMessage(playerid, Cinza, "Você não está fazendo entregas!");
	if(!IsPlayerInRangeOfPoint(playerid, 2.0, rDados[RotaID[playerid]][rX],rDados[RotaID[playerid]][rY],rDados[RotaID[playerid]][rZ]))
	    return SendClientMessage(playerid, Cinza, "Você não está no local da entrega!");
	pDados[playerid][Dinheiro] += rDados[RotaID[playerid]][rValor];
	rDados[RotaID[playerid]][rBloqueio] = 0;
	GivePlayerMoney(playerid, rDados[RotaID[playerid]][rValor]);
	format(String, sizeof String, "~r~+$%d", rDados[RotaID[playerid]][rValor]);
	GameTextForPlayer(playerid, String, 200, 1);
	for(new i = 0; i < MAX_PLAYERS; ++ i)
	{
	    if(pDados[i][Emprego] == CAMINHONEIRO)
	    {
	        format(String, sizeof String, "( Atenção Caminhoneiros ) O Caminhoneiro %s acaba de cumprir a rota %d, agora ela está liberada!", Nome(playerid), RotaID[playerid]);
	        SendClientMessage(i, Amarelo2, String);
		}

	}
	RotaID[playerid] = 555;
	DisablePlayerCheckpoint(playerid);
	return true;
}
COMMAND:rotas(playerid)
{
	new Dialog[500];
	new String[128];
	new file[70];
	format(file, sizeof file, "%s/ultimo.ini", DIRETORIO_CAMINHONEIRO);
	for(new i = 0; i < DOF2_GetInt(file, "Ultimo ID"); i++)
	{
	    if(rDados[i][rBloqueio] == 0)
	    {
			format(String, sizeof String, "{FFFFFF}[ ID:%d ] Nome: [%s] Valor: [$%d] Carga: [%d]\n", rDados[i][rID], rDados[i][rNome], rDados[i][rValor], rDados[i][rCarga]);
		}
	  	else if(rDados[i][rBloqueio] == 1)
	    {
			format(String, sizeof String, "{CC0000}[ ID:%d ] Nome: [%s] Valor: [$%d] Carga: [%d] (aproximadamente %d minutos)\n", rDados[i][rID], rDados[i][rNome], rDados[i][rValor], rDados[i][rCarga], MinProx(rDados[i][rTempo]));
		}
		strcat(Dialog, String);
	}
	ShowPlayerDialog(playerid, DIALOG_NULL, DIALOG_STYLE_LIST, "Rotas Liberadas:", Dialog, "Fechar", #);
	return true;
}
COMMAND:pegarrota(playerid, params[])
{
	new rotaid;
	new String[128];
	new vehicleid = GetPlayerVehicleID(playerid);
	if(!IsPlayerInAnyVehicle(playerid))
	    return SendClientMessage(playerid, Cinza, "Você não está em um veículo.");
	if(!IsTrailerAttachedToVehicle(vehicleid))
	    return SendClientMessage(playerid, Cinza, "Você não está com um trailer.");
	if(pDados[playerid][Emprego] != CAMINHONEIRO)
		return SendClientMessage(playerid, Cinza, "• Apenas pessoal autorizado.");
	if(sscanf(params,"i",rotaid))
	    return SendClientMessage(playerid, Cinza, "Comando: /pegarrota [rotaid]");
	if(rDados[rotaid][rBloqueio] == 1)
	    return SendClientMessage(playerid, Cinza, "Está rota já está ocupada.");
	rDados[rotaid][rBloqueio] = 1;
	rDados[rotaid][rTempo] = 600;
	RotaID[playerid] = rotaid;
	SendClientMessage(playerid, Branco, " ");
	format(String, sizeof String, "======================================================================================");
	SendClientMessage(playerid, Branco, String);
	format(String, sizeof String, "Seu caminhão foi abastecido!");
	SendClientMessage(playerid, Amarelo2, String);
	format(String, sizeof String, "Você pegou a rota %d. Vá até a marca vermelha no seu mini-mapa em 10 minutos!", rotaid);
	SendClientMessage(playerid, Amarelo2, String);
	format(String, sizeof String, "Informações:");
	SendClientMessage(playerid, Cinza, String);
	format(String, sizeof String, "ID: [%d] Nome: [%s] Valor: [%d] Carga: [%d]", rotaid, rDados[rotaid][rNome], rDados[rotaid][rValor], rDados[rotaid][rCarga]);
	SendClientMessage(playerid, Cinza, String);
	SendClientMessage(playerid, Cinza, "Quando chegar na posição digite /entregar para entregar a carga.");
	format(String, sizeof String, "======================================================================================");
	SendClientMessage(playerid, Branco, String);
	SendClientMessage(playerid, Branco, " ");
	SetPlayerCheckpoint(playerid,rDados[rotaid][rX],rDados[rotaid][rY],rDados[rotaid][rZ],7.0);
	return true;
}
//----------------------------------------------------------
//  Comandos dos Empregos: Taxistas.
//----------------------------------------------------------
COMMAND:taximetro(playerid, params[])
{
	new Preco;
	new String[128];
	new vehicleid = GetPlayerVehicleID(playerid);

	if(pDados[playerid][Emprego] != TAXISTA)
	    return SendClientMessage(playerid, Cinza, "Você não é um taxista.");
	if(Taxistas_EmCorrida[playerid])
	    return SendClientMessage(playerid, Cinza, "Seu taximetro já está ativado! Use /encerrar para desligar o taximetro.");
	if(sscanf(params,"i",Preco))
	    return SendClientMessage(playerid, Cinza, "Comando: /taximetro [valor]");
	if(Preco <= 0 || Preco > 50)
	    return SendClientMessage(playerid, Cinza, "Preço muito baixo ou muito abusivo.. Coloque um preço entre 1 e 50.");
    if(!NoTaxi(vehicleid))
        return SendClientMessage(playerid, Cinza, "Você não está em um taxi.");
	Taxistas_CorridaPreco[playerid] = Preco;
	format(String, sizeof String, "[CI:RP]: O Taxista %s acaba de ligar o taximetro, caso queira um taxi ligue para o motorista.", Nome(playerid));
	SendClientMessageToAll(Amarelo2, String);
	SendClientMessageToAll(Cinza, "OBS: Para ver os taxistas online e seu contato digite /taxistas.");
	return true;
}
COMMAND:encerrar(playerid)
{
	if(pDados[playerid][Emprego] != TAXISTA)
	    return SendClientMessage(playerid, Cinza, "Você não é um taxista.");
	if(!Taxistas_EmCorrida[playerid])
	    return SendClientMessage(playerid, Cinza, "Seu taximetro não esta ligado..");
	Taxistas_EmCorrida[playerid] = false;
	SendClientMessage(playerid, Cinza, "Você desligou o taximetro.");
	cmd_me(playerid, "desligou o taximetro.");
	return true;
}
//----------------------------------------------------------
//  Comandos Beta Tester+
//----------------------------------------------------------
COMMAND:servico(playerid)
{
	new Nivel_Admin[16];
	new String[128];
	if(pDados[playerid][Admin] < 1 && pDados[playerid][Emprego] == DESEMPREGADO)
		return SendClientMessage(playerid, Cinza, "• Apenas pessoal autorizado.");
	if(pDados[playerid][Admin] > 0)
	{
	    switch( pDados[playerid][Admin] )
	    {
	        case 1: Nivel_Admin = "Beta Tester";
	        case 2: Nivel_Admin = "Moderador";
	        case 3: Nivel_Admin = "Administrador";
	        case 4: Nivel_Admin = "Supervisor";
	        case 5: Nivel_Admin = "Operador Master";
	        case 6: Nivel_Admin = "Desenvolvedor";
		}

		if( !EmServico[playerid] )
		{
		    EmServico[playerid] = true;
		    SetPlayerHealth(playerid, cellmax);
		    SetPlayerArmour(playerid, 100);
		    if(!strcmp(Nome(playerid), "_Gamer8", false))
		    {
		        SetPlayerSkin(playerid, 0);
			}
			else
			{
		    	SetPlayerSkin(playerid, 217);
			}
		}
		else if( EmServico[playerid] )
		{
		    EmServico[playerid] = false;
		    SetPlayerHealth(playerid, 100);
		    SetPlayerArmour(playerid, 100);
		    SetPlayerSkin(playerid, pDados[playerid][Skin]);
		}

		format(String, sizeof String, "Aviso da Administração: O %s %s acaba de %s.", Nivel_Admin, Nome(playerid), EmServico[playerid] ? ("entrar no modo administrador") : ("sair do modo administrador"));
		SendClientMessageToAll(Amarelo, String);
	}
	return true;
}
COMMAND:definirskin(playerid, params[])
{
	new skinid;
	new String[128];
	if(pDados[playerid][Admin] < 1)
		return SendClientMessage(playerid, Cinza, "• Apenas pessoal autorizado.");
	if( !EmServico[playerid] )
	    return SendClientMessage(playerid, Cinza, "• Apenas para administradores em serviço.");
	if(sscanf(params,"i",skinid))
	    return SendClientMessage(playerid, Cinza, "Comando: /definirskin [skin id]");
	SetPlayerSkin(playerid, skinid);
	pDados[playerid][Skin] = skinid;
	format(String, sizeof String, "» ( /changemyskin ) « Sua skin foi alterada para o id %d.", skinid);
	SendClientMessage(playerid, Amarelo2, String);
	return true;
}
COMMAND:irlocal(playerid)
{
	new Dialog[500];
	if(pDados[playerid][Admin] < 1)
		return SendClientMessage(playerid, Cinza, "• Apenas pessoal autorizado.");
	if( !EmServico[playerid] )
	    return SendClientMessage(playerid, Cinza, "• Apenas para administradores em serviço.");
	strcat(Dialog, "24/7 ( San Fierro )\n");
	strcat(Dialog, "Well stacked pizza (San Fierro)\n");
	ShowPlayerDialog(playerid, DIALOG_TELEPORT, DIALOG_STYLE_LIST, "Teleportes (/irlocal)", Dialog, "Ir", "Cancelar");
	return true;
}
//----------------------------------------------------------
//  Comandos Desenvolvedor
//----------------------------------------------------------
COMMAND:criarcarro(playerid, params[])
{
	new car[3];
	new String[128];
	new Float: Pos[4];
	if( !EmServico[playerid] )
	    return SendClientMessage(playerid, Cinza, "• Apenas para administradores em serviço.");
	if(pDados[playerid][Admin] < 6)
		return SendClientMessage(playerid, Cinza, "• Apenas pessoal autorizado.");
	if(sscanf(params, "iii", car[0], car[1], car[2]))
	    return SendClientMessage(playerid, Cinza, "Comando: /criarcarro [modelo] [cor primaria] [cor secundaria]");

	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	GetPlayerFacingAngle(playerid, Pos[3]);
	CreateVehicle(car[0], Pos[0], Pos[1], Pos[2], Pos[3], car[1], car[2], -1);

	for(new i = 0; i < MAX_PLAYERS; ++i)
	{
	    if( pDados[i][Admin] > 0 )
	    {
	        format(String, sizeof String, "O Desenvolvedor %s acaba de criar um veículo", Nome(playerid));
	        SendClientMessage(i, Cinza, String);
		}
	}
	return true;
}
COMMAND:criarrota(playerid, params[])
{
	new Float: Pos[3];
	new Nome_Rota[50];
	new carga;
	new String[128];
	new int[2];
	if( !EmServico[playerid] )
	    return SendClientMessage(playerid, Cinza, "• Apenas para administradores em serviço.");
	if(pDados[playerid][Admin] < 6)
		return SendClientMessage(playerid, Cinza, "• Apenas pessoal autorizado.");
	if(sscanf(params, "s[50]iii", Nome_Rota, carga, int[0], int[1]))
	    return SendClientMessage(playerid, Cinza, "Comando: /criarrota [nome] [carga] [valor] [exp]");

	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	CriarRota(Pos[0], Pos[1], Pos[2], Nome_Rota, carga, int[0], int[1]);

	new file[70];
	new file2[70];
	format(file2, sizeof file2, "%s/ultimo.ini", DIRETORIO_CAMINHONEIRO);
	for(new i = 0; i < DOF2_GetInt(file2, "Ultimo ID"); ++ i)
	{
		format(file, sizeof file, "%s/ROTA_%d.ini", DIRETORIO_CAMINHONEIRO, i);
		strmid(rDados[i][rNome], DOF2_GetString(file, "Nome"), 0, strlen( DOF2_GetString(file, "Nome") ), 255);
		rDados[i][rCarga] = DOF2_GetInt(file, "Carga");

		rDados[i][rX] = DOF2_GetFloat(file, "X");
		rDados[i][rY] = DOF2_GetFloat(file, "Y");
		rDados[i][rZ] = DOF2_GetFloat(file, "Z");

		rDados[i][rValor] 	 = DOF2_GetInt(file, "Valor");
		rDados[i][rExp]   	 = DOF2_GetInt(file, "Exp");
		rDados[i][rID]    	 = DOF2_GetInt(file, "ID");
		rDados[i][rBloqueio] = DOF2_GetInt(file, "Bloqueio");
		rDados[i][rTempo]    = DOF2_GetInt(file, "Tempo");
	}

	SendClientMessageToAll(Branco, " ");
	format(String, sizeof String, "======================================================================================");
	SendClientMessageToAll(Branco, String);
	format(String, sizeof String, "( Atenção Caminhoneiros ) O Desenvolvedor %s acaba de criar uma nova rota!", Nome(playerid));
	SendClientMessageToAll(Amarelo2, String);
	format(String, sizeof String, "Informações:");
	SendClientMessageToAll(Cinza, String);
	format(String, sizeof String, "Nome: [%s] Carga: [%d] Valor: [%d] Experiencia: [%d]", Nome_Rota, carga, int[0], int[1]);
	SendClientMessageToAll(Cinza, String);
	format(String, sizeof String, "Rota disponivel em qualquer empresa.");
	SendClientMessageToAll(Amarelo2, String);
	format(String, sizeof String, "======================================================================================");
	SendClientMessageToAll(Branco, String);
	SendClientMessageToAll(Branco, " ");
	return true;
}
//----------------------------------------------------------
//
//  Funções Adicionais
//
//----------------------------------------------------------
stock NoTaxi(vehicleid)
{
	for(new i = 0; i < sizeof Veiculo_Taxistas; ++ i)
	{
	    if(vehicleid == Veiculo_Taxistas[i]) return true;
	}
	return false;
}
stock NoCaminhao(vehicleid)
{
	for(new i = 0; i < sizeof Veiculo_Truck; ++ i)
	{
	    if(vehicleid == Veiculo_Truck[i]) return true;
	}
	return false;
}
stock CriarRota(Float:X, Float:Y, Float:Z, nome[], carga, valor, exp)
{
	new file[70];
	new file2[70];
	format(file2, sizeof file2, "%s/ultimo.ini", DIRETORIO_CAMINHONEIRO);
	if(!DOF2_FileExists(file2))
	{
		DOF2_CreateFile(file2);
		DOF2_SetInt(file2, "Ultimo ID", 0);
		DOF2_SaveFile();
	}
	format(file, sizeof file, "%s/ROTA_%d.ini", DIRETORIO_CAMINHONEIRO, DOF2_GetInt(file2, "Ultimo ID"));
	DOF2_CreateFile(file);
	DOF2_SetString(file, "Nome", nome);
	DOF2_SetInt(file, "Carga", carga);
	
	DOF2_SetFloat(file, "X", X);
	DOF2_SetFloat(file, "Y", Y);
	DOF2_SetFloat(file, "Z", Z);

	DOF2_SetInt(file, "Valor", valor);
	DOF2_SetInt(file, "Exp", exp);
	DOF2_SetInt(file, "ID", DOF2_GetInt(file2, "Ultimo ID"));
	DOF2_SetInt(file, "Bloqueio", 0);
	DOF2_SetInt(file, "Tempo", 0);
	
	DOF2_SetInt(file2, "Ultimo ID", DOF2_GetInt(file2, "Ultimo ID") + 1);
	DOF2_SaveFile();
	return true;
}
stock CriarConta(playerid, sendername[], password[])
{
	new file[70];
	format(file, sizeof file, "Contas/%s.ini", sendername);
	if(!DOF2_FileExists(file))
	{
	    DOF2_CreateFile(file);
	    DOF2_SetString(file, "Password", password);
	    DOF2_SetInt(file, "Admin", 0);
	    DOF2_SetInt(file, "Dinheiro", 350);
	    DOF2_SetInt(file, "Skin", 25);

	    DOF2_SetInt(file, "Cigarros", 0);
	    DOF2_SetInt(file, "Camisinha", 0);
	    DOF2_SetInt(file, "Cereal", 0);

	    DOF2_SetInt(file, "Emprego", DESEMPREGADO);
	    DOF2_SaveFile();

		pDados[playerid][Admin] 	= DOF2_GetInt(file, "Admin");
		pDados[playerid][Skin] 		= DOF2_GetInt(file, "Skin");
		pDados[playerid][Dinheiro]  = DOF2_GetInt(file, "Dinheiro");

		pDados[playerid][Cigarros] 	= DOF2_GetInt(file, "Cigarros");
		pDados[playerid][Camisinha] = DOF2_GetInt(file, "Camisinha");
		pDados[playerid][Cereal]  	= DOF2_GetInt(file, "Cereal");
		
		pDados[playerid][Emprego]  	= DOF2_GetInt(file, "Emprego");

		GivePlayerMoney(playerid, pDados[playerid][Dinheiro]);
		Logado[playerid] = true;

		for(new i = 0; i < sizeof Interface; ++ i)
		{
		    TextDrawShowForPlayer(playerid, Interface[i]);
		}

		SetSpawnInfo(playerid, 0, pDados[playerid][Skin], 0.0, 0.0, 0.0, 0.0, -1, -1, -1, -1, -1, -1);
		SpawnPlayer(playerid);
		SetPlayerAttachedObject(playerid, 1, 3026, 1, -0.16, -0.08, 0.0, 0.5, 0.5, 0.0);

		SendClientMessage(playerid, Branco, "Seja bem vindo ao Cidade Roleplay!");
		SendClientMessage(playerid, Branco, "Caso precise de ajuda use /ajuda, se preferir falar com um administrador use /ask.");
	}
	return true;
}

stock SalvarConta(playerid)
{
	new file[70];
	format(file, sizeof file, "Contas/%s.ini", Nome(playerid));
	if(!IsPlayerConnected(playerid)) return print("O Jogador desejado está offline..");
	if(!DOF2_FileExists(file)) return print("Conta desejada inexistente..");
	DOF2_SetInt(file, "Admin", pDados[playerid][Admin]);
	DOF2_SetInt(file, "Skin", pDados[playerid][Skin]);
	DOF2_SetInt(file, "Dinheiro", pDados[playerid][Dinheiro]);
	
	DOF2_SetInt(file, "Cigarros", pDados[playerid][Cigarros]);
	DOF2_SetInt(file, "Camisinha", pDados[playerid][Camisinha]);
	DOF2_SetInt(file, "Cereal", pDados[playerid][Cereal]);
	
	DOF2_SetInt(file, "Emprego", pDados[playerid][Emprego]);
	DOF2_SaveFile();
	return true;
}

stock CarregarConta(playerid, password[])
{
	new file[70];
	format(file, sizeof file, "Contas/%s.ini", Nome(playerid));
	if(!strcmp(password, DOF2_GetString(file, "Password"), true))
	{
		pDados[playerid][Admin] 	= DOF2_GetInt(file, "Admin");
		pDados[playerid][Skin] 		= DOF2_GetInt(file, "Skin");
		pDados[playerid][Dinheiro]  = DOF2_GetInt(file, "Dinheiro");

		pDados[playerid][Cigarros] 	= DOF2_GetInt(file, "Cigarros");
		pDados[playerid][Camisinha] = DOF2_GetInt(file, "Camisinha");
		pDados[playerid][Cereal]  	= DOF2_GetInt(file, "Cereal");
		
		pDados[playerid][Emprego]  	= DOF2_GetInt(file, "Emprego");

		GivePlayerMoney(playerid, pDados[playerid][Dinheiro]);
		Logado[playerid] = true;

		SetSpawnInfo(playerid, 0, pDados[playerid][Skin], 0.0, 0.0, 0.0, 0.0, -1, -1, -1, -1, -1, -1);
		SpawnPlayer(playerid);
		SetPlayerAttachedObject(playerid, 1, 3026, 1, -0.16, -0.08, 0.0, 0.5, 0.5, 0.0);
		
		for(new i = 0; i < sizeof Interface; ++ i)
		{
		    TextDrawShowForPlayer(playerid, Interface[i]);
		}

		SendClientMessage(playerid, Branco, "Seja bem vindo ao Cidade Roleplay!");
		SendClientMessage(playerid, Branco, "Caso precise de ajuda use /ajuda, se preferir falar com um administrador use /ask.");
	}
	else
	{
	    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "..:: Efetuando Login ::..", "Seja bem vindo ao CidadeRP!\nEsta conta está registrada em nosso banco de dados..\nDigite abaixo a sua senha:", "Logar", "Sair");
	    SendClientMessage(playerid, Branco, "SERVER: UNKNOWN PASSWORD!");
	}
	return true;
}

stock Nome(playerid)
{
	new sendername[MAX_PLAYER_NAME];
	GetPlayerName(playerid, sendername, sizeof sendername);
	return ( sendername );
}

stock MinProx(seconds)
{
	new tempo = seconds/60;
	return ( tempo );
}
stock WeaponNameEx(weaponid)
{
	new weaponname[50];
	switch( weaponid )
	{
	    case 555: 				weaponname = "Desarmado";
	    case WEAPON_KNIFE: 		weaponname = "Faca";
	    case WEAPON_COLT45: 	weaponname = "Colt 45";
	    case WEAPON_SILENCED: 	weaponname = "Colt 45+Silenciador";
	    case WEAPON_DEAGLE: 	weaponname = "Deagle";
	    case WEAPON_SHOTGUN: 	weaponname = "Shotgun";
	    case WEAPON_MP5: 		weaponname = "MP5";
	    case WEAPON_AK47: 		weaponname = "AK-47";
	    case WEAPON_M4: 		weaponname = "M4";
	    case WEAPON_RIFLE: 		weaponname = "Rifle";
	    case WEAPON_SNIPER: 	weaponname = "Sniper";
	}
	return ( weaponname );
}
//----------------------------------------------------------
//
//  Fim do Script
//
//----------------------------------------------------------
