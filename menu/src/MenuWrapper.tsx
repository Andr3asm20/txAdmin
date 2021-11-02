import React, { useEffect, useMemo } from "react";
import "./App.css";
import { useIsMenuVisibleValue } from "./state/visibility.state";
import MenuRoot from "./components/MenuRoot";
import { DialogProvider } from "./provider/DialogProvider";
import { useExitListener } from "./hooks/useExitListener";
import { useNuiListenerService } from "./hooks/useNuiListenersService";
import { TopLevelErrorBoundary } from "./components/misc/TopLevelErrorBoundary";
import { debugData } from "./utils/debugData";
import { I18n } from "react-polyglot";
import { useServerCtxValue } from "./state/server.state";
import { getLocale } from "./utils/getLocale";
import { WarnPage } from "./components/WarnPage/WarnPage";
import { IFrameProvider } from "./provider/IFrameProvider";
import { PlayerModalProvider } from "./provider/PlayerModalProvider";
import { txAdminMenuPage, useSetPage } from "./state/page.state";
import { useListenerForSomething } from "./hooks/useListenerForSomething";
import {
  usePlayersFilterIsTemp,
  useSetPlayerFilter,
} from "./state/players.state";
import { Box, styled } from "@mui/material";
import { fetchNui } from "./utils/fetchNui";


//Mock events for browser development
debugData<any>(
  [
    {
      action: "setPermissions",
      data: ["all_permissions"],
    },
    {
      action: "setVisible",
      data: true,
    },
  ],
  3000
);

const MenuWrapper: React.FC = () => {
  const visible = useIsMenuVisibleValue();
  const serverCtx = useServerCtxValue();
  const [playersFilterIsTemp, setPlayersFilterIsTemp] =
    usePlayersFilterIsTemp();
  const setPlayerFilter = useSetPlayerFilter();

  const setPage = useSetPage();
  // These hooks don't ever unmount
  useExitListener();
  useNuiListenerService();

  //Change page back to Main when closed
  useEffect(() => {
    if (visible) return;

    const changeTimer = setTimeout(() => {
      setPage(txAdminMenuPage.Main);
    }, 750);

    if (playersFilterIsTemp) {
      setPlayerFilter("");
      setPlayersFilterIsTemp(false);
    }

    return () => clearInterval(changeTimer);
  }, [visible, playersFilterIsTemp]);

  const localeSelected = useMemo(
    () => getLocale(serverCtx.locale),
    [serverCtx.locale]
  );
  
  //Inform Lua that we are ready to get all variables (server ctx, permissions, debug, etc)
  useEffect(() => {
    fetchNui('reactLoaded').catch(()=>{});
  }, []);

  useListenerForSomething();

  return (
    <TopLevelErrorBoundary>
      <I18n
        locale={serverCtx.locale}
        messages={localeSelected}
        allowMissing={false}
      >
        <IFrameProvider>
          <DialogProvider>
            <PlayerModalProvider>
              <Box
                className="App"
                sx={{
                  opacity: visible ? 1 : 0,
                }}
              >
                <MenuRoot />
              </Box>
            </PlayerModalProvider>
          </DialogProvider>
          <WarnPage />
        </IFrameProvider>
      </I18n>
    </TopLevelErrorBoundary>
  );
};

export default MenuWrapper;
