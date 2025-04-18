void plot_dxdy()
{
    gStyle->SetOptStat(0);
    
    TCut cutS("cutS","abs(s.eTX)<0.05&&abs(s.eTY)<0.05");
    TCut cutT("cutT","abs(t.eTX)<0.05&&abs(t.eTY)<0.05");
    
    TCanvas *c= new TCanvas("dxdy","dxdy",720,720);
    c->Divide(2,3);
    c->cd(3);
    tracks->Draw("s.eTX:s.eScanID.ePlate", cutS ,"colz");
    c->cd(5);
    tracks->Draw("s.eTY:s.eScanID.ePlate", cutS ,"colz");
    c->cd(1);
    tracks->SetLineColor(kRed);
    tracks->Draw("s[0].eScanID.ePlate", cutT ,"");
    tracks->SetLineColor(kBlue);
    tracks->Draw("s[nseg-1].eScanID.ePlate", cutT ,"same");
    TPaveText *t1 = new TPaveText(.6,.6,.8,.8,"NBNDC");
    t1->AddText("First segment");  ((TText*)t1->GetListOfLines()->Last())->SetTextColor(kRed);
    t1->AddText("Last segment"); ((TText*)t1->GetListOfLines()->Last())->SetTextColor(kBlue);
    t1->SetFillColor(kWhite);
    t1->Draw();
    
    c->cd(4)->SetLogy();
    tracks->SetLineColor(kBlack);
    tracks->Draw("npl", cutT ,"");
    tracks->SetLineColor(kGreen);
    tracks->Draw("nseg", cutT ,"same");
    TPaveText *t4 = new TPaveText(.35,.8,.8,.7,"NBNDC");
    t4->AddText("npl");  ((TText*)t4->GetListOfLines()->Last())->SetTextColor(kGreen);
    t4->AddText("nseg"); ((TText*)t4->GetListOfLines()->Last())->SetTextColor(kBlack);
    t4->SetFillColor(kWhite);
    t4->Draw();
    
    
    c->cd(6)->SetLogy();
    tracks->SetLineColor(kBlack);
    tracks->Draw("npl","","");
    tracks->SetLineColor(kGreen);
    tracks->Draw("nseg","","same");
    t4->SetFillColor(kWhite);
    t4->Draw();
    
    
    c->cd(2);
    tracks->SetLineColor(kMagenta);
    tracks->Draw("s.eScanID.ePlate","","");
    tracks->SetLineColor(kCyan);
    tracks->Draw("s.eScanID.ePlate", cutT ,"same");
    TPaveText *t2 = new TPaveText(.85,.85,.95,.95,"NBNDC");
    t2->AddText("all trks");  ((TText*)t2->GetListOfLines()->Last())->SetTextColor(kMagenta);
    t2->AddText("#theta_{X/Y}<0.05"); ((TText*)t2->GetListOfLines()->Last())->SetTextColor(kMagenta+4);
    t2->SetFillColor(kWhite);
    t2->Draw();
}

void q_tr2()
{
    plot_dxdy();
}
