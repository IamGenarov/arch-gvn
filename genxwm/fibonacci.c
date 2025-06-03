void fibonacci(Monitor *mon, int s) {
    unsigned int i, n;
    int nx, ny, nw, nh;
    Client *c;

    // Contar ventanas tiling
    for (n = 0, c = nexttiled(mon->clients); c; c = nexttiled(c->next))
        n++;
    if (n == 0)
        return;

    nx = mon->wx;
    ny = mon->wy;  // corregido para usar wy en vez de 0 (pos y ventana)
    nw = mon->ww;
    nh = mon->wh;

    for (i = 0, c = nexttiled(mon->clients); c; c = nexttiled(c->next)) {
        // Ajuste de tamaño: solo dividir si la mitad es mayor que 2*borde
        int can_divide_h = (i % 2) && (nh / 2 > 2 * c->bw);
        int can_divide_w = !(i % 2) && (nw / 2 > 2 * c->bw);

        if ((can_divide_h || can_divide_w) && i < n - 1) {
            if (i % 2)
                nh /= 2;
            else
                nw /= 2;

            // Actualizar posición según patrón
            switch (i % 4) {
                case 2:
                    if (!s) nx += nw;
                    break;
                case 3:
                    if (!s) ny += nh;
                    break;
            }
        }

        // Movimiento de nx, ny según el patrón en espiral o dwindle
        switch (i % 4) {
            case 0:
                ny += s ? nh : -nh;
                break;
            case 1:
                nx += nw;
                break;
            case 2:
                ny += nh;
                break;
            case 3:
                nx += s ? nw : -nw;
                break;
        }

        // Ajuste inicial del tamaño para la primera ventana
        if (i == 0) {
            if (n != 1)
                nw = mon->ww * mon->mfact;
            ny = mon->wy;
        }
        else if (i == 1) {
            nw = mon->ww - nw;
        }

        resize(c, nx, ny, nw - 2 * c->bw, nh - 2 * c->bw, False);
        i++;
    }
}
