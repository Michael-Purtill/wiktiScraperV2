<script>
    import * as _ from 'lodash';
    import { onMount } from 'svelte';
import Lang from './Lang.svelte';
    
    
    let langList = [];
    let selectedLang = "";
    onMount(async () => {
        fetch("/api/langlist").then((r) => {return r.json()}).then((d) => {langList = _.filter(d.langs, (l) => l != ""); selectedLang = _.filter(d.langs, (l) => l != "")[0] })
    });

    function handleLangSelect(e) {
        selectedLang = e.target.value;
    }
        
</script>
    
    <div id="innerApp" class="langInfoContainer">
        <h3>Please Select a Language</h3>
        {#if langList.length > 0}
        <div>
            <select on:change={handleLangSelect}>
                {#each langList as lang}
                <option value={lang}>{lang}</option>
                {/each}
            </select>
        </div>

        <a href={"lang/" + selectedLang}>Select</a>

        {:else}
            <p>Loading...</p>
        {/if}
    </div>