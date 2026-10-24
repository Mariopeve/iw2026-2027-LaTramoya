package com.aytocadiz.carnaval.ui;

import com.vaadin.flow.component.html.H1;
import com.vaadin.flow.component.html.Paragraph;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.router.Route;
import com.vaadin.flow.server.auth.AnonymousAllowed;

/**
 * Vista de inicio publica de La Tramoya.
 */
@Route("")
@AnonymousAllowed
public class MainView extends VerticalLayout {

    public MainView() {
        setSpacing(true);
        setPadding(true);

        H1 title = new H1("🎭 La Tramoya - Carnaval de Cádiz");
        Paragraph subtitle = new Paragraph("Sistema de gestión del COAC y Archivo Histórico municipal.");

        add(title, subtitle);
    }
}
